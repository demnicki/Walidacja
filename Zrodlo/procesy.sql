/* Proces do strony z walidatorem numerów identyfikacyjnych REGON / NIP / PESEL. */
BEGIN
	nry_id.numer_id(
		a_numer_id  => :P1_NR_ID,
		o_komunikat => :P1_KOM_ID
	);
END;

/* Proces do strony z walidatorem numerów kont bankowych. */
BEGIN
	nry_konta_bankowego.konto_bankowe(
		a_numer     => :P1_NR_BANK,
		o_komunikat => :P1_KOM_BANK
	);
END;