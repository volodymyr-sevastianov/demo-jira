import jwt from "jsonwebtoken";
import createQueries from "./queries/queries";
import createMutations from "./mutations/index";

const queries = createQueries(jwt);
const mutations = createMutations();

export default { ...queries, ...mutations };
