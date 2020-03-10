const createQueries = db => {
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

  return {
    findUsers,
    findCompanies,
    findProjects,
    findTasks,
    hello: () => {
      return "Hi!";
    }
  };
};

export default createQueries;
