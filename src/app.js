import express from "express";
import graphqlHTTP from "express-graphql";
import { buildSchema } from "graphql";
import schemas from "./schemas/schemas.gql";
import { Database } from "./db";

const root = {
  hello: () => {
    return "Hi!";
  }
};

const db = new Database();
db.setSessionRole("anonymous");

db.query(`SELECT * FROM users;`)
  .then(result => {
    console.log(result);
  })
  .catch(err => {
    console.log(err);
  });

const schema = buildSchema(schemas);

const app = express();
app.use(
  "/api",
  graphqlHTTP({
    schema,
    rootValue: root,
    graphiql: true
  })
);

app.listen(5000, () => {
  console.log("Woah??? Its running!");
});
