class AddIdentAutofill < ActiveRecord::Migration
  def change
    execute "
    CREATE OR REPLACE FUNCTION fill_ident_country()
      RETURNS BOOLEAN AS $$
      DECLARE
        changed     BOOLEAN;
        multiplier  INT [];
        multiplier2 INT [];
        multiplier3 INT [];
        multiplier4 INT [];
        r           RECORD;
        control     TEXT;
        total       INT;
        i           INT;
        mod         INT;
        counter     INT;
      BEGIN

        multiplier  := ARRAY [1, 2, 3, 4, 5, 6, 7, 8, 9, 1];
        multiplier2 := ARRAY [3, 4, 5, 6, 7, 8, 9, 1, 2, 3];
        multiplier3 := ARRAY [1, 2, 3, 4, 5, 6, 7];
        multiplier4 := ARRAY [3, 4, 5, 6, 7, 8, 9];

        FOR r IN SELECT id, ident FROM contacts WHERE ident_type = 'priv' AND ident_country_code IS NULL
        LOOP
          IF (length(r.ident) = 11 AND (r.ident ~ '^[0-9]+$') AND (substring(r.ident, 1, 1) = '3' OR substring(r.ident, 1, 1) = '4' OR substring(r.ident, 1, 1) = '5' OR substring(r.ident, 1, 1) = '6'))
          THEN
            total := 0;
            counter := 1;
            FOREACH i IN ARRAY multiplier
            LOOP
              total := (total + (i * to_number(substring(r.ident, counter, 1), '9')));
              counter := (counter + 1);
            END LOOP;
            mod := (total % 11);
            counter := 1;
            IF (mod >= 10)
            THEN
              total = 0;
              FOREACH i IN ARRAY multiplier2
              LOOP
                total := (total + (i *  to_number(substring(r.ident, counter, 1), '9')));
                counter := (counter + 1);
              END LOOP;
              mod := (total % 11);
            END IF;

            IF (mod < 10 AND substring(r.ident, 11, 1) = to_char(mod, 'FM999MI'))
              THEN
                UPDATE contacts SET ident_country_code = 'EE' WHERE id = r.id;
            END IF;
            total = 0;
          END IF;
        END LOOP;

        FOR r IN SELECT id, ident FROM contacts WHERE ident_type = 'org' AND ident_country_code IS NULL
        LOOP
          IF (length(r.ident) = 8 AND (r.ident ~ '^[0-9]+$') AND (substring(r.ident, 1, 1) = '1' OR substring(r.ident, 1, 1) = '8' OR substring(r.ident, 1, 1) = '9'))
          THEN
            total := 0;
            counter := 1;
            FOREACH i IN ARRAY multiplier3
            LOOP
              total := (total + (i * to_number(substring(r.ident, counter, 1), '9')));
              counter := (counter + 1);
            END LOOP;
            mod := total % 11;
            total = 0;
            counter := 1;
            IF (mod >= 10)
            THEN
              total = 0;
              FOREACH i IN ARRAY multiplier4
              LOOP
                total := (total + (i *  to_number(substring(r.ident, counter, 1), '9')));
                counter := (counter + 1);
              END LOOP;
              mod := (total % 11);
            END IF;
            IF (mod < 10 AND (substring(r.ident, 8, 1) = to_char(mod, 'FM999MI')))
            THEN
              UPDATE contacts SET ident_country_code = 'EE' WHERE id = r.id;
            END IF;
          END IF;
        END LOOP;
      RETURN changed;
      END;
      $$  LANGUAGE plpgsql;"
  end

  def down
    execute "DROP FUNCTION IF EXISTS fill_ident_country()"
  end
end
