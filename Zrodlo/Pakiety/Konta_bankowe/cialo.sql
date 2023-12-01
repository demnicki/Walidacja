CREATE OR REPLACE PACKAGE BODY nry_konta_bankowego
IS
	PROCEDURE konto_bankowe(
		a_numer     IN VARCHAR2,
		o_komunikat OUT VARCHAR2
	)
	IS
		z_numer     VARCHAR2(36 CHAR);
		czy_praw    BOOLEAN;
		nazwa_banku VARCHAR2(250 CHAR);
	BEGIN
		z_numer := trim(replace(a_numer, 'PL', ''));
		nry_konta_bankowego.walid_nru_konta(
			a_nr_konta => z_numer,
			o_czy_praw => czy_praw,
			o_nazwa_banku => nazwa_banku
		);
		IF czy_praw THEN
			o_komunikat := 'Numer konta bankowego jest prawidłowy. I jest prowadzony przez: '||nazwa_banku||'.';
		ELSE
			o_komunikat := 'Numer konta bankowego nie jest prawidłowy.';
		END IF;
	END konto_bankowe;

	PROCEDURE walid_nru_konta(
		a_nr_konta    IN CHAR,
		o_czy_praw    OUT BOOLEAN,
		o_nazwa_banku OUT lista_bankow.nazwa_banku%TYPE
		)
	IS
		cialo_nru       CHAR(24 CHAR);
		cyfry_kontrolne CHAR(2 CHAR);
		n               NUMBER(1);
		cyfry_id        lista_bankow.id_banku%TYPE;
		modulacja_nru   NUMBER(30);
	BEGIN
		o_czy_praw := FALSE;
		IF length(a_nr_konta) = 26 THEN
			cyfry_kontrolne := substr(a_nr_konta, 1, 2);
			cyfry_id := substr(a_nr_konta, 3, 4);
			cialo_nru := substr(a_nr_konta, 3, 24);
			modulacja_nru := to_number(cialo_nru || '2521' || cyfry_kontrolne);
			IF mod(modulacja_nru, 97) = 1 THEN
				SELECT count(id_banku) INTO n FROM lista_bankow WHERE id_banku = cyfry_id;
				IF n = 1 THEN
					SELECT nazwa_banku INTO o_nazwa_banku FROM lista_bankow WHERE id_banku = cyfry_id;
					o_czy_praw := TRUE;
				END IF;
			END IF;
		END IF;
	EXCEPTION
		WHEN others THEN
		o_czy_praw := FALSE;
	END walid_nru_konta;
END nry_konta_bankowego;