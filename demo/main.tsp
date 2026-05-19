import "@typespec/http";
import "./shared/pagination.tsp";
using Http;

@service(#{ title: "Pet Store API" })
namespace PetStore;

model Pet {
  @doc("Unique pet identifier")
  id: string;

  @minLength(1)
  name: string;

  kind: "cat" | "dog" | "bird";
  age?: uint8;
}

model CreatePetRequest {
  @minLength(1)
  name: string;

  kind: "cat" | "dog" | "bird";
  age?: uint8;
}

@route("/pets")
interface Pets {
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
