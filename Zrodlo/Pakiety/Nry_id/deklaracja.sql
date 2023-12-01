CREATE OR REPLACE PACKAGE nry_id
IS
	TYPE t_wagi IS VARRAY(14) OF NUMBER(1);

	PROCEDURE numer_id(
		a_numer_id  IN VARCHAR2,
		o_komunikat OUT VARCHAR2
		);

	PROCEDURE walid_pesel(
		a_pesel    IN CHAR,
		o_czy_praw OUT BOOLEAN,
		o_plec     OUT BOOLEAN,
		o_data_ur  OUT DATE
		);

	FUNCTION walid_nip(nip CHAR) RETURN BOOLEAN;
	
	FUNCTION walid_regon_matka(regon CHAR) RETURN BOOLEAN;

	FUNCTION walid_regon_corka(regon CHAR) RETURN BOOLEAN;
END nry_id;