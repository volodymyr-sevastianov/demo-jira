const createProjectMutations = () => {
  const createProject = async ({ project }, { db, user }) => {
    await db.connect();
    db;
    const newProject = JSON.stringify(project);
    const [result] = await db.query(`
      SELECT * FROM create_project('${newProject}');
    `);
    db.release();

    return result;
  };

  const updateProject = async ({ project }, { db, user }) => {
    await db.connect();
    const [result] = await db.query(`
      UPDATE projects
      SET name = '${project.name}'
      WHERE id = ${project.id}
      RETURNING *;
    `);
    db.release();

    return result;
  };

  const deleteProject = async ({ id }, { db, user }) => {
    await db.connect();
    const [result] = await db.query(`
      DELETE FROM projects
      WHERE id = ${id}
      RETURNING *;
    `);
    db.release();

    return result;
  };

  return { createProject, updateProject, deleteProject };
};

export default createProjectMutations;
