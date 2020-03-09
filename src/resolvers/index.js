import createQueries from "./queries/queries";
import { Database } from "../db";
import createMutations from "./mutations/mutations";

const db = new Database();

const queries = createQueries(db);
const mutations = createMutations(db);

export default { ...queries, ...mutations };
