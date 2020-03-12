import express from "express";
import graphqlHTTP from "express-graphql";
import { buildSchema } from "graphql";
import jwt from "jsonwebtoken";
import dotenv from "dotenv";
import schemas from "./schemas/schemas.gql";
import { Database } from "./db";
import resolver from "./resolvers";

dotenv.config();

const schema = buildSchema(schemas);

const app = express();

app.use(express.json());

app.use(
  "/api/:role?",
  graphqlHTTP(async (request, response, graphQLParams) => {
    const db = new Database();
    await db.connect();
    let token;
    let user;
    if (request.headers.authorization) {
      token = request.headers.authorization.replace(/Bearer /, "");
      user = jwt.verify(token, process.env.JWT_SECRET);
      const userExists = await db.query(`
      SELECT * 
      FROM users 
      WHERE id = ${user.id}
        AND email = '${user.email}'
    `);

      if (!userExists) {
        throw new Error("Your account does not exists!");
      }
      db.setSessionRole(request.params.role);
      db.setSessionVariable({ name: "session.accountId", value: user.id });
    }
    db.release();
    return {
      schema,
      rootValue: resolver,
      graphiql: true,
      context: {
        request,
        user,
        db
      }
    };
  })
);

app.listen(5000, () => {
  console.log("Woah??? Its running!");
});
