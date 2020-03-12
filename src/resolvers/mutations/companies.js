const createCompanyMutations = () => {
  const createCompany = async ({ company }, { db, user }) => {
    await db.connect();
    const newCompany = JSON.stringify(company);
    const [result] = await db.query(`
      SELECT * FROM create_company('${newCompany}');
    `);
    db.release();

    return result;
  };

  const updateCompany = async ({ company }, { db, user }) => {
    await db.connect();
    const [result] = await db.query(`
      UPDATE companies
      SET name = '${company.name}'
      WHERE id = ${company.id}
      RETURNING *;
    `);
    db.release();

    return result;
  };

  const deleteCompany = async ({ id }, { db, user }) => {
    await db.connect();
    const [result] = await db.query(`
      DELETE FROM companies
      WHERE id = ${id}
      RETURNING *;
    `);
    db.release();

    return result;
  };

  return { createCompany, updateCompany, deleteCompany };
};

export default createCompanyMutations;
