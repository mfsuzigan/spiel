CREATE TABLE `DESPESAS_FIXAS` (
	`ID`	INTEGER,
	`NOME`	TEXT,
	`VALOR`	NUMERIC
	PRIMARY KEY(`ID`)
);

CREATE UNIQUE INDEX DESPESAS_FIXAS_ID ON DESPESAS_FIXAS (ID);