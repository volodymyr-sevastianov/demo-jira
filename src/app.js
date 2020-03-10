import express from "express";
import graphqlHTTP from "express-graphql";
import { buildSchema } from "graphql";
import jwt from "jsonwebtoken";
import expressJwt from "express-jwt";
import schemas from "./schemas/schemas.gql";
import { Database } from "./db";
import resolver from "./resolvers";

const db = new Database();

const schema = buildSchema(schemas);

const app = express();

app.use(express.json());

app.use("/auth", (request, response, next) => {
  const body = request.body;
  // DO IT email@cac.kek
  db.query(`
    SELECT * FROM users WHERE 
  `);
});

app.use(
  "/api",
  graphqlHTTP((request, response, graphQLParams) => ({
    schema,
    rootValue: resolver,
    graphiql: true,
    context: {
      request: request,
      test: "Example context value"
    }
  }))
);

app.listen(5000, () => {
  console.log("Woah??? Its running!");
});
