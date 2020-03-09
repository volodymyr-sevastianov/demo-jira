const createMutations = db => {
  const createUser = async ({ user }) => {
    const newUser = JSON.stringify(user);
    const [result] = await db.query(`
      SELECT * FROM create_user('${newUser}');
    `);

    return result;
  };

  const createCompany = async ({ company }) => {
    const newCompany = JSON.stringify(company);
    const [result] = await db.query(`
      SELECT * FROM create_company('${newCompany}');
    `);

    return result;
  };

  const createProject = async ({ project }) => {
    const newProject = JSON.stringify(project);
    const [result] = await db.query(`
      SELECT * FROM create_project('${newProject}');
    `);

    return result;
  };

  const createTask = async ({ task }) => {
    const newTask = JSON.stringify(task);
    const [result] = await db.query(`
      SELECT * FROM create_task('${newTask}');
    `);

    return result;
  };

  return {
    createUser,
    createCompany,
    createProject,
    createTask
  };
};

export default createMutations;
