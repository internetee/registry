class AuditMigration
  # rubocop:disable Metrics/MethodLength
  attr_reader :model_name

  TRIGGER_SQL = lambda do |model_name|
    <<~SQL
      CREATE OR REPLACE FUNCTION process_#{model_name}_audit()
      RETURNS TRIGGER AS $process_#{model_name}_audit$
        BEGIN
          IF (TG_OP = 'INSERT') THEN
            INSERT INTO audit.#{model_name.pluralize}
            (object_id, action, recorded_at, old_value, new_value)
            VALUES (NEW.id, 'INSERT', now(), '{}', to_json(NEW)::jsonb);
            RETURN NEW;
          ELSEIF (TG_OP = 'UPDATE') THEN
            INSERT INTO audit.#{model_name.pluralize}
            (object_id, action, recorded_at, old_value, new_value)
            VALUES (NEW.id, 'UPDATE', now(), to_json(OLD)::jsonb, to_json(NEW)::jsonb);
            RETURN NEW;
          ELSEIF (TG_OP = 'DELETE') THEN
            INSERT INTO audit.#{model_name.pluralize}
            (object_id, action, recorded_at, old_value, new_value)
            VALUES (OLD.id, 'DELETE', now(), to_json(OLD)::jsonb, '{}');
            RETURN OLD;
          END IF;
          RETURN NULL;
        END
      $process_#{model_name}_audit$ LANGUAGE plpgsql;

      --- Create the actual trigger
      CREATE TRIGGER process_#{model_name}_audit
      AFTER INSERT OR UPDATE OR DELETE ON #{model_name.pluralize}
      FOR EACH ROW EXECUTE PROCEDURE process_#{model_name}_audit();
    SQL
  end

  def initialize(model_name)
    @model_name = model_name
  end

  def create_table
    sql = <<~SQL
      CREATE TABLE IF NOT EXISTS audit.#{model_name.pluralize} (
           id                 serial NOT NULL,
           object_id          bigint,
           action TEXT NOT NULL CHECK (action IN ('INSERT', 'UPDATE', 'DELETE', 'TRUNCATE')),
           recorded_at        timestamp without time zone,
           old_value          jsonb,
           new_value          jsonb
        );


        ALTER TABLE audit.#{model_name.pluralize} ADD PRIMARY KEY (id);
        CREATE INDEX ON audit.#{model_name.pluralize} USING btree (object_id);
        CREATE INDEX ON audit.#{model_name.pluralize} USING btree (recorded_at)
    SQL

    sql
  end

  def create_trigger
    TRIGGER_SQL.call(model_name)
  end

  def drop
    sql = <<~SQL
      DROP TRIGGER IF EXISTS process_#{model_name}_audit ON #{model_name.pluralize};
      DROP FUNCTION IF EXISTS process_#{model_name}_audit();
      DROP TABLE IF EXISTS audit.#{model_name.pluralize};
    SQL

    sql
  end
  # rubocop:enable Metrics/MethodLength
end
