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

  async query(query, values) {
    console.log(this.guc, query, values);
    return Database.connection.query(`${this.guc} ${query};`, values);
  }

  async queryElevated(query, values) {
    return Database.connection.query(`${query};`, values);
  }
}
