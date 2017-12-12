use Mojo::Base -strict;
use Test::Mojo;
use Test::More;

plan skip_all => 'Mojolicious::Plugin::OpenAPI is required'
  unless eval { require Mojolicious::Plugin::OpenAPI };

use Mojolicious::Lite;

eval { plugin OpenAPI => {url => 'data://main/v3.json', schema => 'v3'} };
ok !$@, 'valid openapi v3 schema' or diag $@;

done_testing;

__DATA__
@@ v3.json
{
  "openapi": "3.0.0",
  "info": {
    "license": {
      "name": "MIT"
    },
    "title": "Swagger Petstore",
    "version": "1.0.0"
  },
  "servers": [
    { "url": "http://petstore.swagger.io/v1" }
  ],
  "paths": {
    "/pets/{petId}": {
      "get": {
        "operationId": "showPetById",
        "tags": [ "pets" ],
        "summary": "Info for a specific pet",
        "parameters": [
          {
            "description": "The id of the pet to retrieve",
            "in": "path",
            "name": "petId",
            "required": true,
            "schema": { "type": "string" }
          }
        ],
        "responses": {
          "default": {
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/Error"
                }
              }
            },
            "description": "unexpected error"
          },
          "200": {
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/Pets"
                }
              }
            },
            "description": "Expected response to a valid request"
          }
        }
      }
    },
    "/pets": {
      "get": {
        "operationId": "listPets",
        "summary": "List all pets",
        "tags": [ "pets" ],
        "parameters": [
          {
            "description": "How many items to return at one time (max 100)",
            "in": "query",
            "name": "limit",
            "required": false,
            "schema": { "type": "integer", "format": "int32" }
          }
        ],
        "responses": {
          "200": {
            "description": "An paged array of pets",
            "headers": {
              "x-next": {
                "schema": { "type": "string" },
                "description": "A link to the next page of responses"
              }
            },
            "content": {
              "application/json": {
                "schema": { "$ref": "#/components/schemas/Pets" }
              }
            }
          },
          "default": {
            "description": "unexpected error",
            "content": {
              "application/json": {
                "schema": { "$ref": "#/components/schemas/Error" }
              }
            }
          }
        }
      },
      "post": {
        "operationId": "createPets",
        "summary": "Create a pet",
        "tags": [ "pets" ],
        "responses": {
          "201": {
            "description": "Null response"
          },
          "default": {
            "description": "unexpected error",
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/Error"
                }
              }
            }
          }
        }
      }
    }
  },
  "components": {
    "schemas": {
      "Pets": {
        "type": "array",
        "items": { "$ref": "#/components/schemas/Pet" }
      },
      "Pet": {
        "required": [ "id", "name" ],
        "properties": {
          "tag": { "type": "string" },
          "id": { "type": "integer", "format": "int64" },
          "name": { "type": "string" }
        }
      },
      "Error": {
        "required": [ "code", "message" ],
        "properties": {
          "code": { "format": "int32", "type": "integer" },
          "message": { "type": "string" }
        }
      }
    }
  }
}
