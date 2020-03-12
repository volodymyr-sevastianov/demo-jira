const createQueries = jwt => {
  const findUsers = async ({ search, order }, { db, user }) => {
    await db.connect();
    const whereClause =
      search && search.name
        ? `WHERE firstname ILIKE %${search.name}% or lastname ILIKE %${search.name}%`
        : "";
    const orderByClause = order ? `ORDER BY ${order};` : "";

    const users = await db.query(`
      SELECT * 
      FROM users 
      ${whereClause}
      ${orderByClause};`);
    db.release();

    return users;
  };

  const findCompanies = async ({ search, order }, { db, user }) => {
    await db.connect();
    const whereClause =
      search && search.name ? `WHERE name ILIKE %${search.name}%` : "";
    const orderByClause = order ? `ORDER BY ${order};` : "";

    const companies = await db.query(`
      SELECT *
      FROM companies
      ${whereClause}
      ${orderByClause};
    `);
    db.release();

    return companies;
  };

  const findProjects = async ({ search, order }, { db, user }) => {
    await db.connect();
    const whereClause =
      search && search.name ? `WHERE name ILIKE %${search.name}%` : "";
    const orderByClause = order ? `ORDER BY ${order};` : "";

    const projects = await db.query(`
      SELECT *
      FROM projects
      ${whereClause}
      ${orderByClause};
  `);
    db.release();

    return projects;
  };

  const findTasks = async ({ search, order }, { db, user }) => {
    await db.connect();
    const whereClause =
      search && search.name ? `WHERE name ILIKE %${search.name}%` : "";
    const orderByClause = order ? `ORDER BY ${order};` : "";
    const tasks = await db.query(`
      SELECT *
      FROM tasks
      ${whereClause}
      ${orderByClause};
  `);
    db.release();

    return tasks;
  };

  const auth = async ({ email, password }, { db }) => {
    await db.connect();
    const [user] = await db.query(`
      SELECT * 
      FROM users 
      WHERE email = '${email}' 
        AND password = '${password}';
    `);
    if (!user) throw new Error("Email or password are incorrect.");
    console.log(user);
    const token = jwt.sign(user, "secret");
    console.log(token);
    db.release();

    return { token };
  };

  return {
    findUsers,
    findCompanies,
    findProjects,
    findTasks,
    auth,
    hello: () => {
      return "Hi!";
    }
  };
};

export default createQueries;
