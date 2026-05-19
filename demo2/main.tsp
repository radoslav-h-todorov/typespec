import "@typespec/http";
import "./shared/pagination.tsp";
import "@typespec/versioning";

using Http;
using TypeSpec.Versioning;

@versioned(Versions)
@service(#{ title: "Pet Store API" })
namespace PetStore;

enum Versions {
  v1,
  v2,
}

// Spread PetBase — add id on top
model Pet {
  id: PetId;
  ...PetBase;

  // 2. Field added only in v2 — invisible in v1 spec
  @added(Versions.v2)
  microchipId?: string;

  // 4. Field removed in v2
  @removed(Versions.v2)
  legacyTag?: string;
}

// Shared base model
model PetBase {
  name: PetName;
  kind: "cat" | "dog" | "bird";
  age?: uint8;
}

// CreatePetRequest = PetBase (no id)
model CreatePetRequest {
  ...PetBase;
}

@route("/pets")
interface Pets {

  @added(Versions.v2)
  @get @route("/pets/microchip/{id}")
  op findByMicrochip(@path id: string): Pet;

  @get
  listPets(@query skip?: int32, @query top?: int32): Page<Pet>;

  // Update createPet
  @post
  createPet(@body b: CreatePetRequest): Pet | ValidationError;

  // Update getPet to return union
  @get
  @route("/{id}")
  getPet(@path id: string): Pet | NotFoundError;

  @put
  @route("/{id}")
  updatePet(@path id: string, @body body: CreatePetRequest): Pet;

  @delete
  @route("/{id}")
  deletePet(@path id: string): void;
}

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

// Custom scalar — UUID identifier
@format("uuid")
scalar PetId extends string;

// Length + regex constraint
@minLength(1)
@maxLength(100)
@pattern("^[A-Za-z ]+$")
scalar PetName extends string;
