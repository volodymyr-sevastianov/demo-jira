import { Pool } from "pg";

const pgConfig = {
  user: "postgres",
  database: "demo-jira",
  password: "root9007"
};

export class Database {
  get guc() {
    this.context.set("role", this.role);

    return Array.from(this.context)
      .filter(([, value]) => value)
      .map(([name, value]) => `SET LOCAL ${name} TO ${value};`)
      .join("");
  }
  context = new Map();
  // role = "anonymous";
  role = "postgres";

  static connection = new Pool(pgConfig);

  setSessionVariable({ name, value }) {
    this.context.set(name, value);
  }

  resetSessionVariables() {
    this.context.clear();
  }

  setSessionRole(role) {
    this.role = role;
  }

  async query(query, values, { rawData } = {}) {
    console.log(this.guc, query, values);
    let result = await Database.connection.query(
      `${this.guc} ${query};`,
      values
    );

    if (!rawData) {
      result = result[result.length - 1].rows;
    }
    return result;
  }

  async queryElevated(query, values) {
    return Database.connection.query(`${query};`, values);
  }
}
