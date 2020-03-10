import jwt from "jsonwebtoken";
import createQueries from "./queries/queries";
import { Database } from "../db";
import createMutations from "./mutations/mutations";

const db = new Database();

const queries = createQueries(db, jwt);
const mutations = createMutations(db);

export default { ...queries, ...mutations };
