const createUserMutations = () => {
  const createUser = async ({ user }, { db, user: loggedUser }) => {
    await db.connect();
    const newUser = JSON.stringify(user);
    const [result] = await db.query(`
      SELECT * FROM create_user('${newUser}');
    `);
    db.release();
    return result;
  };

  const updateUser = async ({ user }, { db, user: loggedUser }) => {
    await db.connect();
    const [result] = await db.query(`
      UPDATE users
      SET firstname = '${user.firstname}'
      WHERE id = ${user.id}
      RETURNING *;
    `);
    db.release();

    return result;
  };

  const deleteUser = async ({ id }, { db, user }) => {
    await db.connect();
    const [result] = await db.query(`
      DELETE FROM users
      WHERE id = ${id}
      RETURNING *;
    `);
    db.release();

    return result;
  };

  const assignUserToTask = async ({ data }, { db, user }) => {
    await db.connect();
    const [result] = await db.query(`
      INSERT INTO public.users_tasks(user_id, task_id)
      VALUES (${data.user_id}, ${data.task_id})
      RETURNING *;
    `);
    db.release();

    return result;
  };
  const addUserToProject = async ({ data }, { db, user }) => {
    await db.connect();
    const [result] = await db.query(`
      INSERT INTO public.users_projects(user_id, project_id, role)
      VALUES (${data.user_id}, ${data.project_id}, '${data.role}')
      RETURNING *;
    `);
    db.release();

    return result;
  };

  return {
    createUser,
    updateUser,
    deleteUser,
    assignUserToTask,
    addUserToProject
  };
};

export default createUserMutations;
