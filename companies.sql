CREATE TABLE cubicles (
  id INTEGER PRIMARY KEY,
  size VARCHAR(255) NOT NULL,
  employee_id INTEGER,

  FOREIGN KEY(employee_id) REFERENCES employee(id)
);

CREATE TABLE employees (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL,
  company_id INTEGER,

  FOREIGN KEY(company_id) REFERENCES employee(id)
);

CREATE TABLE companies (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL
);

INSERT INTO
  companies (id, name)
VALUES
  (1, "Foogle"), (2, "Silverman Sachs");

INSERT INTO
  employees (id, fname, lname, company_id)
VALUES
  (1, "Austin", "Stehling", 1),
  (2, "Chris", "Petillo", 1),
  (3, "Brandon", "Stehling", 2);

INSERT INTO
  cubicles (id, size, employee_id)
VALUES
  (1, "Large", 1),
  (2, "Small", 2),
  (3, "Medium", 3);
