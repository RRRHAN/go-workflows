CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE IF NOT EXISTS instances (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  instance_id VARCHAR(128) NOT NULL,
  execution_id VARCHAR(128) NOT NULL,
  parent_instance_id VARCHAR(128),
  parent_execution_id VARCHAR(128),
  parent_schedule_event_id BIGINT,
  metadata JSONB,
  state INT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  completed_at TIMESTAMP,
  locked_until TIMESTAMP,
  sticky_until TIMESTAMP,
  worker VARCHAR(64),
  queue VARCHAR(128) DEFAULT '',

  CONSTRAINT idx_instances_instance_id_execution_id UNIQUE (instance_id, execution_id)
);

CREATE INDEX idx_instances_locked_until_completed_at_queue 
  ON instances (completed_at, locked_until, sticky_until, worker, queue);

CREATE INDEX idx_instances_parent_instance_id_parent_execution_id 
  ON instances (parent_instance_id, parent_execution_id);


CREATE TABLE IF NOT EXISTS pending_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id VARCHAR(128) NOT NULL,
  sequence_id BIGINT NOT NULL,
  instance_id VARCHAR(128) NOT NULL,
  execution_id VARCHAR(128) NOT NULL,
  event_type INT NOT NULL,
  timestamp TIMESTAMP NOT NULL,
  schedule_event_id BIGINT NOT NULL,
  attributes JSONB NOT NULL,
  visible_at TIMESTAMP
);

CREATE INDEX idx_pending_events_inid_exid 
  ON pending_events (instance_id, execution_id);

CREATE INDEX idx_pending_events_inid_exid_visible_at_schedule_event_id 
  ON pending_events (instance_id, execution_id, visible_at, schedule_event_id);


CREATE TABLE IF NOT EXISTS history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id VARCHAR(64) NOT NULL,
  sequence_id BIGINT NOT NULL,
  instance_id VARCHAR(128) NOT NULL,
  execution_id VARCHAR(128) NOT NULL,
  event_type INT NOT NULL,
  timestamp TIMESTAMP NOT NULL,
  schedule_event_id BIGINT NOT NULL,
  attributes JSONB NOT NULL,
  visible_at TIMESTAMP
);

CREATE INDEX idx_history_instance_id_execution_id 
  ON history (instance_id, execution_id);

CREATE INDEX idx_history_instance_id_execution_id_sequence_id 
  ON history (instance_id, execution_id, sequence_id);


CREATE TABLE IF NOT EXISTS activities (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  activity_id VARCHAR(64) NOT NULL,
  instance_id VARCHAR(128) NOT NULL,
  execution_id VARCHAR(128) NOT NULL,
  event_type INT NOT NULL,
  timestamp TIMESTAMP NOT NULL,
  schedule_event_id BIGINT NOT NULL,
  attributes JSONB NOT NULL,
  visible_at TIMESTAMP,
  locked_until TIMESTAMP,
  worker VARCHAR(64),
  queue VARCHAR(128) DEFAULT '',

  CONSTRAINT idx_activities_instance_id_execution_id_activity_id_worker 
    UNIQUE (instance_id, execution_id, activity_id, worker)
);

CREATE INDEX idx_activities_locked_until_queue 
  ON activities (locked_until, queue);

CREATE TABLE IF NOT EXISTS attributes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id VARCHAR(128) NOT NULL,
  instance_id VARCHAR(128) NOT NULL,
  execution_id VARCHAR(128) NOT NULL,
  data JSONB NOT NULL,

  CONSTRAINT idx_attributes_instance_id_execution_id_event_id UNIQUE (instance_id, execution_id, event_id)
);

CREATE INDEX idx_attributes_event_id 
  ON attributes (event_id);

