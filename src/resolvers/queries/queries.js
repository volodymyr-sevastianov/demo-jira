const createQueries = (db, jwt) => {
  const findUsers = async ({ search, order }, context) => {
    console.log(context.request.headers);

    const whereClause =
      search && search.name
        ? `WHERE firstname ILIKE %${search.name}% or lastname ILIKE %${search.name}%`
        : "";
    const orderByClause = order ? `ORDER BY ${order};` : "";
    return db.query(
      `SELECT * 
    FROM users 
    ${whereClause}
    ${orderByClause}`
    );
  };

  const findCompanies = async (root, { search, order }) => {
    const whereClause =
      search && search.name ? `WHERE name ILIKE %${search.name}%` : "";
    const orderByClause = order ? `ORDER BY ${order};` : "";
    return db.query(`
    SELECT *
    FROM companies
    ${whereClause}
    ${orderByClause}
  `);
  };

  const findProjects = async (root, { search, order }) => {
    const whereClause =
      search && search.name ? `WHERE name ILIKE %${search.name}%` : "";
    const orderByClause = order ? `ORDER BY ${order};` : "";
    return db.query(`
    SELECT *
    FROM projects
    ${whereClause}
    ${orderByClause}
  `);
  };

  const findTasks = async (root, { search, order }) => {
    const whereClause =
      search && search.name ? `WHERE name ILIKE %${search.name}%` : "";
    const orderByClause = order ? `ORDER BY ${order};` : "";
    return db.query(`
    SELECT *
    FROM tasks
    ${whereClause}
    ${orderByClause}
  `);
  };

  const auth = async ({ email, password }) => {
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
