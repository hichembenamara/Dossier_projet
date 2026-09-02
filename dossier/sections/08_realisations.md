# VIII. Réalisations

Cette section présente les composants les plus significatifs de l'application, avec le code tel qu'il est dans le dépôt de référence. Chaque extrait indique son fichier, et chaque extrait est suivi des raisons qui ont conduit à l'écrire ainsi. L'ordre suit la trame attendue : interfaces, composants métier, accès aux données, autres composants, sécurité.

## 1. Interfaces utilisateur

### L'écran de recommandations

*Figure 27 — Page `/me/recommandations` : formulaire de contraintes, cartes d'exercices avec animation et calories estimées, bouton d'enregistrement de la séance (capture `bloc34_recommandations_sport`).*

La page est écrite dans `frontend/src/features/me/pages/Recommandations.tsx`. Elle charge le profil de l'utilisateur pour préremplir les formulaires, puis envoie une requête de recommandation et affiche le résultat en cartes.

**Extrait 7 — `frontend/src/features/me/pages/Recommandations.tsx`, chargement du profil et appel de l'API**

```tsx
export function RecommandationsPage() {
  const [selectedMode, setSelectedMode] = useState<RecommendationMode | null>(null);
  const [mealForm, setMealForm] = useState<MealFormState>(initialMealForm);
  const [sportForm, setSportForm] = useState<SportFormState>(initialSportForm);
  const [profileLoaded, setProfileLoaded] = useState(false);

  const profile = useQuery({
    queryKey: ["/api/me/profile"],
    queryFn: () => apiRequest<User>("/api/me/profile")
  });

  useEffect(() => {
    if (!profile.data || profileLoaded) return;
    setMealForm(mealFormFromProfile(profile.data));
    setSportForm(sportFormFromProfile(profile.data));
    setProfileLoaded(true);
  }, [profile.data, profileLoaded]);

  const mutation = useMutation({
    mutationFn: async (payload: RecommendationRequest): Promise<RecommendationResponse> => {
      const token = getAuthToken();
      const response = await fetch("/api/ai/recommandations", {
        method: "POST",
        credentials: "include",
        headers: {
          "Content-Type": "application/json",
          ...(token ? { authorization: `Bearer ${token}` } : {})
        },
        body: JSON.stringify(payload)
      });
      if (!response.ok) throw new Error(`Erreur ${response.status}`);
      return response.json();
    }
  });

  if (profile.isLoading) return <LoadingState />;
  if (profile.isError) return <ErrorState message={profile.error.message} onRetry={() => profile.refetch()} />;
  // ...
}
```

Pourquoi ce choix : TanStack Query sépare deux natures d'appel. Le profil est une lecture mise en cache (`useQuery`) : si l'utilisateur revient sur la page, il n'est pas rechargé. La génération de recommandations est une action (`useMutation`) : elle n'est jamais rejouée automatiquement, ce qui compte quand un appel au LLM prend plusieurs secondes. Les trois états `isLoading`, `isError` et données sont rendus par des composants partagés (`LoadingState`, `ErrorState`, `EmptyState` dans `components/ui/states.tsx`), ce qui donne le même comportement sur les 34 écrans. Les types `User`, `RecommendationRequest` et `RecommendationResponse` viennent de `types/domain.ts` et reflètent les schémas Pydantic du backend.

### La garde de rôle

*Figure 28 — Page `/admin/controles-qualite` : tableau filtré et paginé des contrôles (capture Playwright à produire).*

**Extrait 8 — `frontend/src/components/role-guard.tsx`, intégral**

```tsx
"use client";

import { useRouter } from "next/navigation";
import { useEffect } from "react";
import { LoadingState } from "@/src/components/ui/states";
import { useAuth } from "@/src/features/auth/auth-provider";
import type { Role } from "@/src/types/domain";

export function RoleGuard({ roles, children }: { roles: Role[]; children: React.ReactNode }) {
  const { user, status } = useAuth();
  const router = useRouter();

  useEffect(() => {
    if (status === "anonymous") {
      router.replace("/login");
      return;
    }
    if (status === "authenticated" && (!user || !roles.includes(user.role))) {
      router.replace(user?.role === "UTILISATEUR" ? "/me/dashboard" : "/admin/dashboard");
    }
  }, [roles, router, status, user]);

  if (status === "loading") {
    return <LoadingState label="Verification de la session..." />;
  }

  if (!user || !roles.includes(user.role)) {
    return <LoadingState label="Redirection..." />;
  }

  return <>{children}</>;
}
```

Pourquoi ce choix : chaque espace (`/me`, `/admin`, `/super-admin`) enveloppe ses pages dans `RoleGuard` avec la liste des rôles admis. Un visiteur anonyme est renvoyé vers la connexion ; un utilisateur connecté qui tape une URL d'administration est renvoyé vers son propre tableau de bord. Ce composant ne protège rien à lui seul, et c'est voulu : l'API refuse de toute façon les appels sans le bon rôle (extrait 21). La garde côté client évite seulement d'afficher un écran vide ou une série d'erreurs 403. C'est de la défense en profondeur : le frontend guide, l'API décide.

### Accessibilité

Les formulaires utilisent des libellés associés aux champs (`components/ui/forms.tsx`), les tableaux ont des en-têtes de colonnes, les boutons d'action portent un texte et pas seulement une icône, et la navigation latérale est utilisable au clavier. Les graphiques Recharts sont accompagnés de leurs valeurs en cartes (`KpiCard`), pour ne pas dépendre de la couleur seule. Un audit RGAA complet n'a pas été mené ; les points ci-dessus sont ceux vérifiés sur les écrans principaux.

## 2. Composants métier

### Le moteur de recommandations à règles

Le moteur (`backend/app/services/recommendations.py`, classe `RecommendationEngine`) produit une recommandation sans appel externe, à partir du profil, des dernières mesures et des catalogues. Il sert de socle : la route `/api/ai/recommandations` l'exécute d'abord, puis demande au LLM d'enrichir le résultat.

**Extrait 9a — `backend/app/services/recommendations.py`, construction du contexte**

```python
def build(self, db: Session, user: Utilisateur, request: RecommendationRequest) -> RecommendationResponse:
    request = self._request_with_user_defaults(user, request)
    latest_bio = self._latest_biometrie(db, user.utilisateur_id)
    latest_sleep = self._latest_sommeil(db, user.utilisateur_id)
    active_objective = self._active_objective(db, user.utilisateur_id)

    height = user.taille_cm or (latest_bio.taille_cm if latest_bio else None)
    weight = latest_bio.poids_kg if latest_bio else None
    imc = latest_bio.imc if latest_bio else None
    if imc is None and weight and height:
        height_m = float(height) / 100
        imc = round(float(weight) / (height_m * height_m), 2) if height_m else None

    objective_label = request.objectif_principal or (active_objective.type_objectif if active_objective else None) or "sante"
    goal = self._goal_key(objective_label)
    sport_level = self._sport_level(request.niveau_sportif or latest_training_level)

    nutrition, nutrition_messages = self._nutrition_recommendations(db, user.utilisateur_id, request, goal)
    sport, sport_messages = self._sport_recommendations(db, user.utilisateur_id, request, goal, sport_level)
    return RecommendationResponse(
        source="local_rules",
        contexte=context,
        contraintes_prises_en_compte=self._constraints_summary(request),
        nutrition=nutrition,
        sport=sport,
        messages=[m for m in [*nutrition_messages, *sport_messages] if m],
    )
```

**Extrait 9b — `backend/app/services/recommendations.py`, règles d'exclusion**

```python
def food_block_reasons(self, name: str, category: str | None, allergies: list[str], regime: str | None) -> list[str]:
    text = self._normalize(f"{name} {category or ''}")
    reasons: list[str] = []
    for allergy in allergies:
        allergy_key = self._normalize(allergy).replace(" ", "_")
        aliases = ALLERGEN_ALIASES.get(allergy_key) or (self._normalize(allergy),)
        if any(alias and self._normalize(alias) in text for alias in aliases):
            reasons.append(f"allergie ou aliment evite: {allergy}")
    if regime:
        regime_key = self._normalize(regime).replace(" ", "_").replace("-", "_")
        blockers = REGIME_BLOCKERS.get(regime_key, ())
        if any(self._normalize(term) in text for term in blockers):
            reasons.append(f"regime incompatible: {regime}")
    return reasons

def equipment_is_allowed(self, needed: list[str], available: list[str]) -> bool:
    needed_keys = self._canonical_equipment(needed)
    needed_keys.discard("bodyweight")
    if not needed_keys:
        return True
    available_keys = self._canonical_equipment(available)
    if "gym" in available_keys:
        return True
    return needed_keys.issubset(available_keys)

def _exercise_contraindications(self, exercice: Exercice, constraints: list[str]) -> list[str]:
    if not constraints:
        return []
    text = self._normalize(" ".join([exercice.nom, exercice.body_part_principale or "",
                                     exercice.muscle_cible_principal or "", " ".join(self._exercise_muscles(exercice))]))
    constraint_text = self._normalize(" ".join(constraints))
    contraindications: list[str] = []
    if any(t in constraint_text for t in ("genou", "knee")) and any(t in text for t in ("leg", "upper legs", "quads", "glutes", "calves", "jambe", "squat", "lunge")):
        contraindications.append("contrainte genou: exercice bas du corps evite")
    if any(t in constraint_text for t in ("dos", "lombaire", "back")) and any(t in text for t in ("back", "waist", "spine", "deadlift", "row", "dos")):
        contraindications.append("contrainte dos: charge ou flexion du tronc a eviter")
    if any(t in constraint_text for t in ("cardiaque", "coeur", "hypertension", "tension")):
        contraindications.append("contrainte cardio: intensite moderee recommandee")
    return contraindications
```

Pourquoi ce choix : sur des données de santé, une recommandation doit pouvoir être expliquée. Chaque exclusion produit une phrase lisible (« allergie ou aliment evite: arachide », « contrainte genou: exercice bas du corps evite ») qui est renvoyée à l'utilisateur dans `contraintes_prises_en_compte`. Les règles sont déterministes : le même profil donne la même réponse, ce qui rend le jeu d'essai de la section IX reproductible. Les tables `ALLERGEN_ALIASES` et `REGIME_BLOCKERS` gèrent les synonymes (« peanut », « cacahuète », « arachide ») parce que le catalogue d'aliments est en anglais et le profil en français. La méthode `equipment_is_allowed` traite un cas fréquent : un exercice au poids du corps est toujours possible, et un abonnement en salle donne accès à tout.

### L'enrichissement par LLM local

**Extrait 10 — `backend/app/services/ai_enhanced.py`, appel d'Ollama et sélection dans le catalogue**

```python
def _safe_json(s: str):
    try:
        return json.loads(s)
    except Exception:
        return None


class OllamaLLMService:
    async def _call_ollama(self, prompt: str, json_mode: bool = False, temperature: float | None = None) -> str:
        payload: dict = {"model": self.model, "prompt": prompt, "stream": False}
        if json_mode:
            payload["format"] = "json"
        if temperature is not None:
            payload["options"] = {"temperature": temperature}
        async with httpx.AsyncClient(timeout=120.0) as client:
            response = await client.post(f"{self.base_url}/api/generate", json=payload)
            response.raise_for_status()
            return response.json().get("response", "")

    async def select_training_plan(self, profile: dict, program: dict, catalog: list[dict], nb_exercices: int = 5) -> list[dict]:
        if not catalog:
            return []
        catalogue_lignes = "\n".join(
            f"- id={c['id']} | {c['nom']} | groupe: {c['groupe']} | muscle: {c['muscle']} | materiel: {c['materiel']}"
            for c in catalog
        )
        prompt = (
            "Reponds UNIQUEMENT avec un JSON valide, sans texte autour. "
            "Tu es coach sportif certifie qui construit une seance 100% personnalisee.\n\n"
            f"CATALOGUE D'EXERCICES DISPONIBLES:\n{catalogue_lignes}\n\n"
            f"PROFIL DE L'UTILISATEUR: objectif {program.get('objectif')}, niveau {program.get('niveau')}, "
            f"lieu {program.get('lieu')}, materiel {program.get('materiel')}, douleurs {program.get('douleur')}\n"
            f"CONSIGNES: propose exactement {nb_exercices} exercices, privilegie les id du catalogue, "
            "jamais un exercice qui sollicite une zone douloureuse ...\n"
            'Format JSON STRICT: {"exercices":[{"id":12,"nom":"...","series":3,"repetitions":"10-12","justification":"..."}]}'
        )
        raw = await self._call_ollama(prompt, json_mode=True, temperature=0.3)
        parsed = _safe_json(raw)
        # ... extraction de la liste "exercices", validation de chaque élément
```

Pourquoi ce choix : le LLM ne choisit pas librement, il choisit dans un catalogue déjà filtré par les règles (lieu, matériel, douleurs). Chaque exercice retenu porte l'identifiant de la table `exercice`, ce qui permet d'afficher l'animation GIF réelle et d'estimer les calories. Trois précautions rendent la sortie exploitable : le mode `format: json` d'Ollama force une réponse JSON, la température basse (0,3) limite les variations, et `_safe_json` renvoie `None` plutôt qu'une exception si le modèle bavarde quand même. Si la liste est trop courte ou vide, la route complète avec une sélection déterministe (`_fallback_selection`), et l'utilisateur reçoit toujours une séance. Le délai de 120 s est volontairement long : un modèle d'un milliard de paramètres sur un portable sans GPU met parfois plus de trente secondes.

### La route d'analyse de repas et son repli

**Extrait 11 — `backend/app/modules/ai_features.py`, route `POST /api/ai/analyse-repas`**

```python
async def analyse_repas(
    image: UploadFile = File(..., description="Photo du repas (JPEG/PNG)"),
    settings: Settings = Depends(get_settings),
    user: Utilisateur = Depends(current_user),
) -> MealAnalysisResponse:
    image_bytes = await image.read()
    if len(image_bytes) > 10_000_000:
        raise HTTPException(status_code=413, detail="Image trop grande (max 10 Mo)")

    service = GeminiVisionService(settings)
    if not service.is_available():
        document_store.log_ai_call(user.utilisateur_id, "gemini", "gemini-2.5-flash", "unavailable", 0,
                                   {"reason": "GEMINI_API_KEY manquante"})
        raise HTTPException(status_code=503, detail="Gemini Vision non disponible — configurez GEMINI_API_KEY dans .env")

    started = time.perf_counter()
    try:
        foods_raw = await service.analyze(image_bytes)
    except Exception as exc:  # on journalise puis on relaie l'erreur
        document_store.log_ai_call(user.utilisateur_id, "gemini", "gemini-2.5-flash", "error",
                                   int((time.perf_counter() - started) * 1000), {"error": type(exc).__name__})
        raise
    # Liste vide = rien d'exploitable (erreur HTTP, parse, timeout) -> fallback.
    document_store.log_ai_call(user.utilisateur_id, "gemini", "gemini-2.5-flash",
                               "success" if foods_raw else "fallback",
                               int((time.perf_counter() - started) * 1000),
                               {"foods_count": len(foods_raw), "fallback": not foods_raw})

    foods = [DetectedFood(name=f.get("name", "inconnu"), confidence=float(f.get("confidence", 0.0)),
                          quantity_g=f.get("quantity_g"),
                          macros=FoodMacros(**f["macros"]) if f.get("macros") else None)
             for f in foods_raw]
    response = MealAnalysisResponse(foods=foods, total_macros=_sum_macros(foods_raw), source="gemini-2.5-flash")
    document_store.save_meal_analysis(user.utilisateur_id, response.model_dump(mode="json"), source="gemini-2.5-flash")
    return response
```

Pourquoi ce choix : la route est un contrôleur mince. Elle valide l'entrée (taille), délègue au service, journalise chaque issue possible (`unavailable`, `error`, `success`, `fallback`) avec sa durée, et persiste le résultat. Le journal `ai_provider_calls` est ce qui permet ensuite à un administrateur de voir, sur `/api/ai/ai-calls/history`, combien d'appels échouent et en combien de temps. L'absence de clé donne une erreur 503 explicite plutôt qu'un résultat vide : l'exploitant sait quoi corriger.

## 3. Composants d'accès aux données SQL et NoSQL

### CRUD générique et pagination (SQL)

Dix-neuf ressources sont exposées par un seul mécanisme : `create_crud_router` construit un routeur complet (liste, détail, création, mise à jour, suppression) à partir d'une configuration.

**Extrait 12 — `backend/app/modules/resources.py` et `backend/app/core/pagination.py`**

```python
@dataclass
class ResourceConfig:
    path: str
    model: type
    pk: str
    owner_field: str | None = None
    soft_delete_field: str | None = None
    soft_delete_value: Any = None
    sortable_fields: tuple[str, ...] = ()
    searchable_fields: tuple[str, ...] = ()


def _base_query(model: type, owner_field: str | None, user: Utilisateur) -> Select[Any]:
    stmt = select(model)
    if owner_field and user.role == "UTILISATEUR":
        stmt = stmt.where(getattr(model, owner_field) == user.utilisateur_id)
    return stmt
```

```python
def apply_sort(stmt, model, pagination, *, sortable: tuple[str, ...], default_field: str):
    """Apply sort_by/sort_order with whitelist; fall back to default_field desc."""
    field = pagination.sort_by if pagination.sort_by in sortable else default_field
    column = getattr(model, field)
    return stmt.order_by(column.asc() if pagination.sort_order == "asc" else column.desc())


def apply_search(stmt, model, pagination, *, searchable: tuple[str, ...]):
    """Apply LIKE search on whitelisted text fields."""
    if not pagination.search or not searchable:
        return stmt
    pattern = f"%{pagination.search}%"
    clauses = [getattr(model, field).ilike(pattern) for field in searchable if hasattr(model, field)]
    return stmt.where(or_(*clauses)) if clauses else stmt


def paginated_response(data, page, page_size, total, *, filters=None):
    return {
        "data": data,
        "meta": {"page": page, "page_size": page_size, "total": total,
                 "total_pages": ceil(total / page_size) if total else 0},
        "filters": filters or {},
    }
```

Pourquoi ce choix : le filtre par propriétaire est appliqué dans la requête SQL, pas dans le code de chaque route, donc un utilisateur ne peut pas lire les mesures d'un autre même en forgeant un identifiant. Les colonnes de tri et de recherche sont des listes blanches déclarées dans la configuration : un paramètre `sort_by=mot_de_passe_hash` retombe sur la colonne par défaut au lieu de provoquer une erreur ou une fuite. La recherche utilise `ilike` avec un paramètre lié, donc pas d'injection possible. Toutes les listes sont paginées et renvoient le même enveloppe `{data, meta, filters}`, que le composant `data-table` du frontend consomme sans adaptation.

### Modèles SQLAlchemy

**Extrait 13 — `backend/app/db/models.py`, mixin d'audit et modèle `Utilisateur` (début)**

```python
class TimestampMixin:
    cree_le: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)


class Utilisateur(Base):
    __tablename__ = "utilisateur"
    __table_args__ = (
        UniqueConstraint("email", name="uq_utilisateur_email"),
        UniqueConstraint("nom_utilisateur", name="uq_utilisateur_nom_utilisateur"),
        UniqueConstraint("gym_external_id", name="uq_utilisateur_gym_external_id"),
        UniqueConstraint("sleep_external_id", name="uq_utilisateur_sleep_external_id"),
    )

    utilisateur_id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    organisation_id: Mapped[int | None] = mapped_column(ForeignKey("organisation.organisation_id"), nullable=True)
    gym_external_id: Mapped[str | None] = mapped_column(String(120))
    sleep_external_id: Mapped[str | None] = mapped_column(String(120))
    nom_utilisateur: Mapped[str] = mapped_column(String(120), nullable=False)
    prenom: Mapped[str | None] = mapped_column(String(120))
    # ... 26 autres colonnes : profil déclaratif, rôle, statut, mot_de_passe_hash
```

Pourquoi ce choix : le style déclaratif de SQLAlchemy 2.0 (`Mapped[...]`) donne des types vérifiables par l'éditeur et par mypy. Les contraintes d'unicité sont nommées, ce qui rend les messages d'erreur lisibles et les migrations prévisibles. Les identifiants externes des deux jeux de données sources (`gym_external_id`, `sleep_external_id`) sont ce qui permet à l'ETL de reconnaître un utilisateur déjà importé et de mettre à jour au lieu de dupliquer.

### Client MongoDB tolérant aux pannes (NoSQL)

**Extrait 14 — `backend/app/db/mongo.py`**

```python
_client: "MongoClient | None" = None
_database = None
_state = "unknown"  # unknown | ready | unavailable
_last_failure = 0.0
_RETRY_COOLDOWN_SECONDS = 20.0


def _connect():
    global _client, _database, _state, _last_failure
    settings = get_settings()
    try:
        client = MongoClient(settings.mongo_url,
                             serverSelectionTimeoutMS=settings.mongo_timeout_ms,
                             connectTimeoutMS=settings.mongo_timeout_ms,
                             uuidRepresentation="standard")
        client.admin.command("ping")
    except PyMongoError as exc:  # on degrade proprement
        _state = "unavailable"
        _last_failure = time.monotonic()
        logger.warning("MongoDB indisponible (%s): persistance NoSQL en mode degrade.", exc)
        return None
    _client, _database, _state = client, client[settings.mongo_db_name], "ready"
    return _database


def get_mongo_db():
    """Retourne la base Mongo, ou ``None`` si indisponible (jamais d'exception)."""
    settings = get_settings()
    if not settings.mongo_enabled:
        return None
    if _database is not None and _state == "ready":
        return _database
    if _state == "unavailable" and (time.monotonic() - _last_failure) < _RETRY_COOLDOWN_SECONDS:
        return None
    return _connect()


def mongo_status() -> str:
    """Statut lisible pour le healthcheck: ok | unavailable | disabled."""
    if not get_settings().mongo_enabled:
        return "disabled"
    return "ok" if get_mongo_db() is not None else "unavailable"
```

Pourquoi ce choix : le délai de sélection du serveur est de 800 ms (`mongo_timeout_ms`), pas les 30 s par défaut de PyMongo ; une base absente ne fige donc pas les requêtes. Après un échec, le client n'insiste pas pendant 20 secondes (`_RETRY_COOLDOWN_SECONDS`), ce qui évite de ralentir chaque appel IA quand Mongo est réellement arrêté, puis retente tout seul. `get_mongo_db` ne lève jamais : c'est le contrat sur lequel s'appuie tout le reste.

**Extrait 15 — `backend/app/services/document_store.py`, collection indexée et écriture**

```python
def _collection(name: str):
    db = mongo.get_mongo_db()
    if db is None:
        return None
    collection = db[name]
    if name not in _indexed:
        try:
            collection.create_index([("utilisateur_id", 1), ("created_at", DESCENDING)])
            _indexed.add(name)
        except PyMongoError as exc:
            logger.warning("Index Mongo non cree sur %s: %s", name, exc)
    return collection


def _save(name: str, utilisateur_id: int, source: str, payload: dict[str, Any]) -> str | None:
    collection = _collection(name)
    if collection is None:
        return None
    document = {"utilisateur_id": utilisateur_id, "source": source,
                "created_at": datetime.now(timezone.utc), "payload": payload}
    try:
        result = collection.insert_one(document)
        return str(result.inserted_id)
    except PyMongoError as exc:
        logger.warning("Ecriture Mongo echouee sur %s: %s", name, exc)
        mongo.invalidate()
        return None
```

*Figure 29 — Document réel de la collection `recommendations` vu dans MongoDB Compass (capture à produire).*

Pourquoi ce choix : tous les documents ont la même enveloppe (`utilisateur_id`, `source`, `created_at`, `payload`), seul `payload` varie. L'index composé correspond exactement à la seule requête faite sur ces collections : les N derniers documents d'un utilisateur, du plus récent au plus ancien. En cas d'erreur d'écriture, `mongo.invalidate()` force une reconnexion au prochain appel plutôt que de garder un client cassé. Le scénario « `docker compose stop mongo` pendant une démonstration » a été joué devant le jury : l'analyse de repas continue de répondre, `/health` indique `documentaire: unavailable`, et tout revient à la normale au redémarrage sans intervention.

## 4. Autres composants

### Contrat d'erreur uniforme

**Extrait 17 — `backend/app/core/errors.py`**

```python
class ApiError(Exception):
    def __init__(self, status_code: int, code: str, message: str, details: Any = None) -> None:
        self.status_code = status_code
        self.code = code
        self.message = message
        self.details = details


def error_payload(code: str, message: str, details: Any = None) -> dict[str, Any]:
    return {"error": {"code": code, "message": message, "details": details}}


def register_error_handlers(app: FastAPI) -> None:
    @app.exception_handler(ApiError)
    async def api_error_handler(_: Request, exc: ApiError) -> JSONResponse:
        return JSONResponse(status_code=exc.status_code,
                            content=error_payload(exc.code, exc.message, exc.details))

    @app.exception_handler(RequestValidationError)
    async def validation_error_handler(_: Request, exc: RequestValidationError) -> JSONResponse:
        errs = exc.errors()
        message = "La requete est invalide."
        if errs:
            first = errs[0]
            loc = [str(p) for p in first.get("loc", []) if p not in ("body", "query", "path")]
            message = f"Champ '{'.'.join(loc) if loc else '?'}' : {first.get('msg', 'invalide')}."
        return JSONResponse(status_code=422, content=error_payload("validation_error", message, errs))

    @app.exception_handler(IntegrityError)
    async def integrity_error_handler(_: Request, exc: IntegrityError) -> JSONResponse:
        return JSONResponse(status_code=409,
                            content=error_payload("conflict", "La contrainte de donnees est violee.", str(exc.orig)))
```

Pourquoi ce choix : toutes les erreurs, qu'elles viennent du code métier (`ApiError`), de la validation Pydantic ou d'une contrainte de base, ont la même forme `{"error": {"code", "message", "details"}}`. Le client (`ApiClientError` dans `api.ts`) n'a qu'un seul format à lire, et le message de validation nomme le champ fautif en français au lieu de renvoyer la structure brute de Pydantic.

### Journalisation corrélée

**Extrait 18 — `backend/app/core/middleware.py`, intégral**

```python
class RequestLogMiddleware(BaseHTTPMiddleware):
    """Attache un request_id et émet une ligne de log par requête HTTP."""

    async def dispatch(self, request: Request, call_next) -> Response:
        request_id = request.headers.get("x-request-id") or uuid.uuid4().hex[:12]
        request.state.request_id = request_id
        log = bind_context(request_id=request_id)
        start = time.perf_counter()
        try:
            response = await call_next(request)
        except Exception:
            duration_ms = (time.perf_counter() - start) * 1000
            log.exception("request_failed method={} path={} duration_ms={:.1f}",
                          request.method, request.url.path, duration_ms)
            raise
        duration_ms = (time.perf_counter() - start) * 1000
        response.headers["x-request-id"] = request_id
        log.info("{} {} -> {} ({:.1f} ms)", request.method, request.url.path, response.status_code, duration_ms)
        return response
```

Pourquoi ce choix : un identifiant de requête est accepté depuis le client ou généré, propagé dans le contexte de journalisation et renvoyé dans la réponse. Quand un utilisateur signale un problème, l'identifiant affiché permet de retrouver la ligne de journal correspondante. La durée est mesurée avec `perf_counter`, y compris en cas d'exception.

### Traçabilité du pipeline ETL

*Figure 30 — Pipeline ETL en cinq étapes, des fichiers sources aux tables métier (archify, source `dossier/figures/sources/pipeline_etl.mmd`).*

**Extrait 19 — `healthai_etl/etl_common.py`, exécution tracée et règles de qualité déclaratives**

```python
def create_execution(conn, source_id: int) -> int:
    result = conn.execute(text("""
        INSERT INTO execution_etl (
          source_id, statut, demarre_le, lignes_lues, lignes_valides,
          lignes_invalides, nb_doublons_supprimes, nb_valeurs_corrigees,
          nb_rejets, taux_qualite, message
        ) VALUES (:source_id, 'EN_COURS', NOW(), 0, 0, 0, 0, 0, 0, NULL, NULL)
    """), {"source_id": source_id})
    return int(result.lastrowid)


def seed_quality_rules(conn) -> dict[str, int]:
    rules = [
        ("food", "Food_Item", "FOOD_REQUIRED_ITEM", "NULLABILITE", "ERREUR", "Nom aliment obligatoire"),
        ("food", "Calories (kcal)", "FOOD_CAL_RANGE", "BORNE", "AVERT", "Calories entre 0 et 3000"),
        ("gym", "Weight (kg)", "GYM_WEIGHT_RANGE", "BORNE", "ERREUR", "Poids plausible entre 20 et 350 kg"),
        ("gym", "BPM", "GYM_BPM_ORDER", "COHERENCE", "ERREUR", "bpm_max >= bpm_moyen >= bpm_repos"),
        ("gym", "BMI", "GYM_IMC_COH", "COHERENCE", "AVERT", "IMC coherent avec poids et taille"),
        ("sleep", "Blood Pressure", "SLEEP_BP_FORMAT", "FORMAT", "ERREUR", "Format SYS/DIA valide"),
        ("sleep", "Blood Pressure", "SLEEP_BP_ORDER", "COHERENCE", "ERREUR", "SYS > DIA"),
        ("sleep", "Sleep Duration", "SLEEP_HOURS_RANGE", "BORNE", "ERREUR", "Sommeil entre 0 et 24h"),
        ("exercise", "exerciseId", "EX_REQUIRED_ID", "NULLABILITE", "ERREUR", "ID exercice obligatoire"),
        # ... 15 règles au total, de 5 types : NULLABILITE, BORNE, FORMAT, COHERENCE, REFERENTIEL
    ]
    for entite, champ, code, type_regle, severite, description in rules:
        conn.execute(text("""
            INSERT INTO regle_qualite (entite, nom_champ, code_regle, type_regle, severite, description, actif)
            VALUES (:entite, :champ, :code, :type_regle, :severite, :description, 1)
            ON DUPLICATE KEY UPDATE nom_champ = VALUES(nom_champ), type_regle = VALUES(type_regle), ...
        """), {...})
```

Pourquoi ce choix : chaque exécution commence par une ligne `EN_COURS` dans `execution_etl` et se termine par ses compteurs (`finish_execution`), si bien qu'un import interrompu reste visible comme tel dans l'espace administrateur. Les règles de qualité sont des données, pas du code : un administrateur peut désactiver une règle depuis `/admin/regles-qualite` sans redéploiement, et `ON DUPLICATE KEY UPDATE` rend l'initialisation rejouable. Chaque décision (acceptée, avertissement, rejetée) est écrite dans `controle_qualite_donnee` avec la valeur observée et, le cas échéant, la valeur corrigée.

## 5. Éléments de sécurité

### Hachage des mots de passe

**Extrait 20 — `backend/app/core/security.py`, lignes 30-47**

```python
def hash_password_pbkdf2_sha256(password: str, salt: str | None = None, iterations: int = 210000) -> str:
    salt = salt or secrets.token_urlsafe(12)
    digest = hashlib.pbkdf2_hmac("sha256", password.encode("utf-8"), salt.encode("utf-8"), iterations)
    digest_b64 = base64.b64encode(digest).decode("ascii").strip()
    return f"pbkdf2_sha256${iterations}${salt}${digest_b64}"


def verify_password(password: str, encoded: str | None) -> bool:
    if not encoded:
        return False
    try:
        algorithm, iterations_raw, salt, expected = encoded.split("$", 3)
        if algorithm != "pbkdf2_sha256":
            return False
        candidate = hash_password_pbkdf2_sha256(password, salt=salt, iterations=int(iterations_raw))
        return hmac.compare_digest(candidate, encoded)
    except (ValueError, TypeError):
        return False
```

Pourquoi ce choix : un sel aléatoire par mot de passe (`secrets.token_urlsafe`), un nombre d'itérations stocké avec le condensé, et une comparaison en temps constant. Le format `algorithme$itérations$sel$condensé` est celui de Django ; il permet d'augmenter les itérations pour les nouveaux comptes sans invalider les anciens, puisque `verify_password` relit le nombre d'itérations dans la chaîne. C'est précisément ce qui rend possible le passage à 600 000 itérations décrit en section X. Le même hachage est utilisé par l'ETL (`hash_password_demo`) pour les comptes générés, afin qu'un seul format existe en base.

### Authentification et rôles

**Extrait 21 — `backend/app/core/security.py`, lignes 104-136**

```python
def current_user(authorization: str | None = Header(default=None), db: Session = Depends(get_db)) -> Utilisateur:
    if not authorization or not authorization.lower().startswith("bearer "):
        raise ApiError(401, "unauthorized", "Authentification requise.")
    payload = decode_token(authorization.split(" ", 1)[1], "access")
    user = db.get(Utilisateur, int(payload["sub"]))
    if not user or user.statut != "ACTIF":
        raise ApiError(401, "unauthorized", "Utilisateur introuvable ou inactif.")
    return user


def require_roles(*roles: str):
    def dependency(user: Utilisateur = Depends(current_user)) -> Utilisateur:
        if user.role not in roles:
            raise ApiError(403, "forbidden", "Droits insuffisants.")
        return user
    return dependency
```

*Figure 31 — Swagger : réponse 403 sur une route d'administration appelée avec un compte utilisateur (capture à produire).*

Pourquoi ce choix : `current_user` vérifie le jeton *et* l'état du compte en base à chaque requête ; désactiver un utilisateur (`statut` autre qu'`ACTIF`) prend effet immédiatement, sans attendre l'expiration de son jeton. `require_roles` se compose par-dessus : les deux codes sont distincts (401 pour « qui êtes-vous ? », 403 pour « vous n'avez pas le droit »), ce que le frontend utilise pour rediriger vers la connexion dans un cas et vers le tableau de bord dans l'autre.

### Session : jetons courts et cookie de rafraîchissement

**Extrait 22 — `backend/app/modules/auth.py`, cookie de rafraîchissement et limitation de débit**

```python
def _set_refresh_cookie(response: Response, user: Utilisateur) -> None:
    settings = get_settings()
    refresh_token = create_token(str(user.utilisateur_id), "refresh",
                                 timedelta(days=settings.refresh_token_days), {"role": user.role})
    response.set_cookie(
        "refresh_token",
        refresh_token,
        httponly=True,
        secure=settings.environment == "production",
        samesite="strict",
        max_age=settings.refresh_token_days * 24 * 60 * 60,
    )


@router.post("/login")
@limiter.limit("10/minute")
def login(...):
    ...


@router.post("/forgot-password")
@limiter.limit("5/minute")
def forgot_password(...):
    ...
```

Pourquoi ce choix : le jeton d'accès (30 min) vit en mémoire côté client et n'est jamais écrit dans `localStorage`, donc un script injecté ne peut pas le lire. Le jeton de rafraîchissement (7 jours) est dans un cookie `HttpOnly` (inaccessible à JavaScript) et `SameSite=Strict` (jamais envoyé depuis un autre site, ce qui neutralise la CSRF sur `/refresh`). L'attribut `secure` n'est activé qu'en production pour permettre le développement en HTTP local. La limitation de débit sur la connexion et la réinitialisation de mot de passe freine la force brute et l'énumération de comptes.

### Rafraîchissement sérialisé côté client

**Extrait 23 — `frontend/src/lib/api.ts`**

```ts
let refreshPromise: Promise<string | null> | null = null;

async function refreshAccessToken() {
  if (!refreshPromise) {
    refreshPromise = rawRequest<{ access_token: string }>("/api/auth/refresh", { method: "POST", auth: false, retry: false })
      .then((data) => {
        authHandlers.setToken(data.access_token);
        return data.access_token;
      })
      .catch(() => {
        authHandlers.setToken(null);
        authHandlers.onUnauthorized();
        return null;
      })
      .finally(() => {
        refreshPromise = null;
      });
  }
  return refreshPromise;
}

// dans rawRequest :
if (response.status === 401 && options.auth !== false && options.retry !== false) {
  const refreshed = await refreshAccessToken();
  if (refreshed) {
    return rawRequest<T>(path, { ...options, retry: false });
  }
  throw new ApiClientError(401, { code: "unauthorized", message: "Session expiree." });
}
```

Pourquoi ce choix : un tableau de bord lance cinq ou six requêtes en parallèle. Si le jeton vient d'expirer, toutes reçoivent 401 en même temps. Sans la promesse partagée, le client enverrait cinq appels à `/refresh` ; avec elle, un seul rafraîchissement a lieu et les cinq requêtes sont rejouées avec le nouveau jeton. L'option `retry: false` sur la requête rejouée empêche une boucle si le second appel échoue encore.
