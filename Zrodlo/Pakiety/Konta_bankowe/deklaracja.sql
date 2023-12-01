CREATE OR REPLACE PACKAGE nry_konta_bankowego
IS
	PROCEDURE konto_bankowe(
		a_numer     IN VARCHAR2,
		o_komunikat OUT VARCHAR2
	);

	PROCEDURE walid_nru_konta(
		a_nr_konta    IN CHAR,
		o_czy_praw    OUT BOOLEAN,
		o_nazwa_banku OUT lista_bankow.nazwa_banku%TYPE
		);
END nry_konta_bankowego;