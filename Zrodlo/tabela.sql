CREATE TABLE lista_bankow(
id_banku    CHAR(4 CHAR) NOT NULL,
nazwa_banku VARCHAR2(250 CHAR),
CONSTRAINT klucz_id PRIMARY KEY (id_banku)
);