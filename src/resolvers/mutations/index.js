import createCompanyMutations from "./companies";
import createProjectMutations from "./projects";
import createUserMutations from "./tasks";
import createTaskMutations from "./users";

const createMutations = () => {
  const companyMutations = createCompanyMutations();
  const projectMutations = createProjectMutations();
  const userMutations = createUserMutations();
  const taskMutations = createTaskMutations();

  return {
    ...companyMutations,
    ...userMutations,
    ...projectMutations,
    ...taskMutations
  };
};

export default createMutations;
