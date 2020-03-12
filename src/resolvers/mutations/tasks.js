const createTaskMutations = () => {
  const createTask = async ({ task }, { db, user }) => {
    await db.connect();
    const newTask = JSON.stringify(task);
    const [result] = await db.query(`
      SELECT * FROM create_task('${newTask}');
    `);
    db.release();

    return result;
  };

  const updateTask = async ({ task }, { db, user }) => {
    await db.connect();
    const [result] = await db.query(`
      UPDATE tasks
      SET name = '${task.name}'
      WHERE id = ${task.id}
      RETURNING *;
    `);
    db.release();

    return result;
  };

  const deleteTask = async ({ id }, { db, user }) => {
    await db.connect();
    const [result] = await db.query(`
      DELETE FROM tasks
      WHERE id = ${id}
      RETURNING *;
    `);
    db.release();

    return result;
  };

  return { createTask, updateTask, deleteTask };
};

export default createTaskMutations;
