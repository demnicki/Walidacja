CREATE OR REPLACE PACKAGE BODY nry_id
IS
	PROCEDURE numer_id(
		a_numer_id  IN VARCHAR2,
		o_komunikat OUT VARCHAR2
		)
	IS
		z_numer_id       VARCHAR2(14 CHAR);
		dlugosc_nru      NUMBER(2);
		z_pesel_czy_praw BOOLEAN;
		z_plec           BOOLEAN;
		z_data_ur        DATE;
	BEGIN
		z_numer_id := trim(a_numer_id);
		dlugosc_nru := length(z_numer_id);
		CASE
			dlugosc_nru
		WHEN 9 THEN
			IF nry_id.walid_regon_matka(z_numer_id) THEN
				o_komunikat := 'To jest prawidłowy numer REGON podmiotu typu matka.';
			ELSE
				o_komunikat := 'To nie jest prawidłowy numer REGON.';
			END IF;
		WHEN 10 THEN
			IF nry_id.walid_nip(z_numer_id) THEN
				o_komunikat := 'To jest prawidłowy NIP.';
			ELSE
				o_komunikat := 'To nie jest prawidłowy NIP.';
			END IF;
		WHEN 11 THEN
			nry_id.walid_pesel(
				a_pesel    => z_numer_id,
				o_czy_praw => z_pesel_czy_praw,
				o_plec     => z_plec,
				o_data_ur  => z_data_ur
				);
			IF z_pesel_czy_praw THEN
				IF z_plec THEN
					o_komunikat := 'Numer PESEL jest prawidłowy. Mężczyzna urodzony dnia '||to_char(z_data_ur, 'DD-MON-YYYY')||' roku.';
				ELSE
					o_komunikat := 'Numer PESEL jest prawidłowy. Kobieta urodzona dnia '||to_char(z_data_ur, 'DD-MON-YYYY')||' roku.';
				END IF;
			ELSE
				o_komunikat := 'To nie jest prawidłowy numer PESEL.';
			END IF;
		WHEN 14 THEN
			IF nry_id.walid_regon_corka(z_numer_id) THEN
				o_komunikat := 'To jest prawidłowy numer REGON podmiotu typu córka.';
			ELSE
				o_komunikat := 'To nie jest prawidłowy numer REGON.';
			END IF;
		ELSE
			o_komunikat := 'To nie jest prawidłowy format numeru identyfikacyjnego.';
		END CASE;

	END;

	PROCEDURE walid_pesel(
		a_pesel    IN CHAR,
		o_czy_praw OUT BOOLEAN,
		o_plec     OUT BOOLEAN,
		o_data_ur  OUT DATE
		)
	IS
		suma_wag        NUMBER(4) := 0;
		cyfra_1_pesel   NUMBER(1);
		cyfra_3_pesel   NUMBER(1);
		cyfra_10_pesel  NUMBER(1);
		cyfra_11_pesel  NUMBER(1);
		cyfra_kontrolna NUMBER(1);		
		wagi t_wagi := t_wagi(1, 3, 7, 9, 1, 3, 7, 9, 1, 3);
	BEGIN
		o_plec := FALSE;
		o_czy_praw := FALSE;
		o_data_ur := NULL;
		IF length(a_pesel) = 11 THEN
			cyfra_1_pesel := to_number(substr(a_pesel, 1, 1));
			cyfra_3_pesel := to_number(substr(a_pesel, 3, 1));
			cyfra_10_pesel := to_number(substr(a_pesel, 10, 1));
			cyfra_11_pesel := to_number(substr(a_pesel, 11, 1));
			IF cyfra_3_pesel = 0 OR cyfra_3_pesel = 1 THEN
				FOR i IN 1..wagi.COUNT LOOP
					suma_wag := suma_wag + (to_number(substr(a_pesel, i, 1)) * wagi(i));
				END LOOP;
				cyfra_kontrolna := substr(suma_wag, -1);
				IF cyfra_kontrolna != 0 THEN
					cyfra_kontrolna := 10 - cyfra_kontrolna;
				END IF;
				IF cyfra_kontrolna = cyfra_11_pesel THEN
					IF cyfra_10_pesel = 1 OR
					cyfra_10_pesel = 3 OR
					cyfra_10_pesel = 5 OR
					cyfra_10_pesel = 7 OR
					cyfra_10_pesel = 9 THEN
						o_plec := TRUE;
					END IF;
					IF cyfra_1_pesel > 4 THEN
						o_data_ur := to_date(19||substr(a_pesel, 1, 6), 'YYYYMMDD');
					ELSE
						o_data_ur := to_date(20||substr(a_pesel, 1, 6), 'YYYYMMDD');
					END IF;
					o_czy_praw := TRUE;
				END IF;			
			END IF;
		END IF;
	END walid_pesel;

	FUNCTION walid_nip(nip CHAR) RETURN BOOLEAN IS
		wagi t_wagi := t_wagi(6, 5, 7, 2, 3, 4, 5, 6, 7);
		cyfra_kontrolna NUMBER(1);
		cyfra_10_nip    NUMBER(1);
		suma_wag        NUMBER(4):= 0;
	BEGIN
		IF length(nip) = 10 THEN
			cyfra_10_nip := to_number(substr(nip, 10, 1));
			FOR i IN 1..wagi.COUNT LOOP
				suma_wag := suma_wag + (to_number(substr(nip, i, 1)) * wagi(i));
			END LOOP;
			cyfra_kontrolna := mod(suma_wag, 11);
			IF cyfra_10_nip = cyfra_kontrolna THEN
				RETURN TRUE;
			ELSE
				RETURN FALSE;
			END IF;
		ELSE
			RETURN FALSE;
		END IF;		
	END walid_nip;

	FUNCTION walid_regon_matka(regon CHAR) RETURN BOOLEAN IS
		wagi t_wagi := t_wagi(8, 9, 2, 3, 4, 5, 6, 7);
		cyfra_kontrolna NUMBER(1);
		cyfra_9_regon   NUMBER(1);
		suma_wag        NUMBER(3):= 0;
	BEGIN
		IF length(regon) = 9 THEN
			cyfra_9_regon := to_number(substr(regon, 9, 1));
			FOR i IN 1..wagi.COUNT LOOP
				suma_wag := suma_wag + (to_number(substr(regon, i, 1)) * wagi(i));
			END LOOP;
			cyfra_kontrolna := mod(suma_wag, 11);
			IF cyfra_9_regon = cyfra_kontrolna THEN
				RETURN TRUE;
			ELSE
				RETURN FALSE;
			END IF;
		ELSE
			RETURN FALSE;
		END IF;		
	END walid_regon_matka;

	FUNCTION walid_regon_corka(regon CHAR) RETURN BOOLEAN IS
		wagi t_wagi := t_wagi(2, 4, 8, 5, 0, 9, 7, 3, 6, 1, 2, 4, 8);
		cyfra_kontrolna NUMBER(2);
		cyfra_14_regon  NUMBER(1);
		suma_wag        NUMBER(4):= 0;
	BEGIN
		IF length(regon) = 14 THEN
			cyfra_14_regon := to_number(substr(regon, 14, 1));
			FOR i IN 1..wagi.COUNT LOOP
				suma_wag := suma_wag + (to_number(substr(regon, i, 1)) * wagi(i));
			END LOOP;
			cyfra_kontrolna := mod(suma_wag, 11);
			IF cyfra_14_regon = cyfra_kontrolna THEN
				RETURN TRUE;
			ELSE
				RETURN FALSE;
			END IF;
		ELSE
			RETURN FALSE;
		END IF;		
	END walid_regon_corka;
END nry_id;