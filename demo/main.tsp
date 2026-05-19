import "@typespec/http";
import "./shared/pagination.tsp";
using Http;

@service(#{ title: "Pet Store API" })
namespace PetStore;

// ── Custom scalars ────────────────────────────────────────────────

/** UUID-formatted pet identifier */
@format("uuid")
scalar PetId extends string;

/** Pet name: letters and spaces only, 1–100 chars */
@minLength(1)
@maxLength(100)
@pattern("^[A-Za-z ]+$")
scalar PetName extends string;

// ── Base model (shared fields) ────────────────────────────────────

/** Common writable fields shared by Pet and CreatePetRequest */
model PetBase {
  name: PetName;
  kind: "cat" | "dog" | "bird";
  age?: uint8;
}

// ── Concrete models using spread ──────────────────────────────────

model Pet {
  @doc("Unique pet identifier")
  id: PetId;
  ...PetBase; // spread all PetBase fields in
}

model CreatePetRequest {
  ...PetBase; // same fields, without id
}

// ── Operations ────────────────────────────────────────────────────

@route("/pets")
interface Pets {
  @get
  listPets(@query skip?: int32, @query top?: int32): Page<Pet>;

  @post
  createPet(@body b: CreatePetRequest): Pet | ValidationError;

  @get
  @route("/{id}")
  getPet(@path id: PetId): Pet | NotFoundError;

  @put
  @route("/{id}")
  updatePet(@path id: PetId, @body body: CreatePetRequest): Pet;

  @delete
  @route("/{id}")
  deletePet(@path id: PetId): void;
}

// ── Error models ──────────────────────────────────────────────────

@error
model NotFoundError {
  @statusCode code: 404;
  message: string;
}

@error
model ValidationError {
  @statusCode code: 400;
  message: string;
  fields: string[];
}
