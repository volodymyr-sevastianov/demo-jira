import express from "express";
import graphqlHTTP from "express-graphql";
import { buildSchema } from "graphql";
import schemas from "./schemas/schemas.gql";
import { Database } from "./db";
import resolver from "./resolvers";

const schema = buildSchema(schemas);

const app = express();
app.use(
  "/api",
  graphqlHTTP({
    schema,
    rootValue: resolver,
    graphiql: true
  })
);

app.listen(5000, () => {
  console.log("Woah??? Its running!");
});
