import { Pool } from "pg";

const pgConfig = {
  user: "postgres",
  database: "demo-jira",
  password: "root9007"
};

export class Database {
  static pool = new Pool(pgConfig);

  get guc() {
    this.context.set("role", this.role);
    console.log(this.context);

    return Array.from(this.context)
      .filter(([, value]) => value)
      .map(([name, value]) => `SET LOCAL ${name} TO ${value};`)
      .join("");
  }
  context = new Map();
  // role = "anonymous";
  role = "postgres";

  async connect() {
    this.connection = await Database.pool.connect();
  }

  release() {
    this.connection.release(true);
  }

  setSessionVariable({ name, value }) {
    this.context.set(name, value);
  }

  resetSessionVariables() {
    this.context.clear();
  }

  setSessionRole(role) {
    this.role = role ? role : this.role;
  }

  async query(query, values, { rawData } = {}) {
    console.log(this.guc, query, values);
    let result = await this.connection.query(`${this.guc} ${query};`, values);

    if (!rawData) {
      result = result[result.length - 1].rows;
    }
    return result;
  }

  async queryElevated(query, values) {
    return this.connection.query(`${query};`, values);
  }
}
