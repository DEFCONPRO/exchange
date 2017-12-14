class CreateTables < ActiveRecord::Migration[5.1]
  def change

    enable_extension "hstore"

    create_table :repos do |t|
      t.string   :type            # Repo::BugZilla, Repo::GitHub, Repo::Cvrf
      t.string   :name            # mvscorg/xdmarket
      t.hstore   :xfields,  null: false, default: {}
      t.jsonb    :jfields,  null: false, default: {}
      t.datetime :synced_at
      t.string   :exref
      t.string   :uuref
      t.timestamps
    end
    add_index :repos, :exref
    add_index :repos, :uuref
    add_index :repos, :type
    add_index :repos, :name
    add_index :repos, :jfields, using: :gin
    add_index :repos, :xfields, using: :gin

    create_table :bugs do |t|
      t.string   :type             # BugZilla, GitHub, Cve
      t.hstore   :xfields,  null: false, default: {}
      t.jsonb    :jfields,  null: false, default: {}
      t.datetime :synced_at
      t.string   :exref
      t.string   :uuref
      t.timestamps
    end
    add_index :bugs, :exref
    add_index :bugs, :uuref
    add_index :bugs, :type
    add_index :bugs, :jfields, using: :gin
    add_index :bugs, :xfields, using: :gin

    create_table :offers do |t|
      t.string   :type                      # BuyBid, SellBid, BuyAsl, SellAsk
      t.string   :repo_type                 # BugZilla, GitHub, CVE
      t.integer  :user_id                   # the party who made the offer
      t.integer  :prototype_id              # optional offer prototype
      t.integer  :amendment_id              # the generating amendment
      t.integer  :reoffer_parent_id         # for ReOffers - an Offer
      t.integer  :salable_position_id       # for SaleOffers - a Position
      t.integer  :volume, default: 1        # Greater than zero
      t.float    :price , default: 0.50     # between 0.00 and 1.00
      t.float    :value
      t.boolean  :poolable, default: true   # for reserve pooling
      t.boolean  :aon     , default: false  # All Or None
      t.string   :status                    # open, suspended, cancelled, ...
      t.datetime :expiration
      t.tsrange  :maturation_range
      t.hstore   :xfields,  null: false, default: {}
      t.jsonb    :jfields,  null: false, default: {}
      t.string   :exref
      t.string   :uuref
      t.timestamps
    end
    add_index :offers, :type
    add_index :offers, :user_id
    add_index :offers, :prototype_id
    add_index :offers, :amendment_id
    add_index :offers, :reoffer_parent_id
    add_index :offers, :salable_position_id
    add_index :offers, :poolable
    add_index :offers, :volume
    add_index :offers, :price
    add_index :offers, :value
    add_index :offers, :exref
    add_index :offers, :uuref
    add_index :offers, :maturation_range, using: :gist
    add_index :offers, :xfields         , using: :gin
    add_index :offers, :jfields         , using: :gin

    create_table :contracts do |t|
      t.integer  :prototype_id        # optional contract prototype
      t.string   :type                # GitHub, BugZilla, ...
      t.string   :status              # open, matured, resolved
      t.string   :awarded_to          # fixed, unfixed
      t.datetime :maturation
      t.hstore   :xfields,  null: false, default: {}
      t.jsonb    :jfields,  null: false, default: {}
      t.string   :exref
      t.string   :uuref
      t.timestamps
    end
    add_index :contracts, :prototype_id
    add_index :contracts, :exref
    add_index :contracts, :uuref
    add_index :contracts, :xfields, using: :gin
    add_index :contracts, :jfields, using: :gin

    # ----- STATEMENT FIELDS -----
    %i(bugs offers contracts).each do |table|
      add_column table, :stm_bug_id  , :integer
      add_column table, :stm_repo_id , :integer
      add_column table, :stm_title   , :string
      add_column table, :stm_status  , :string
      add_column table, :stm_labels  , :string
      add_column table, :stm_xfields , :hstore , null: false, default: {}
      add_column table, :stm_jfields , :jsonb  , null: false, default: {}

      add_index table, :stm_repo_id
      add_index table, :stm_bug_id
      add_index table, :stm_title
      add_index table, :stm_status
      add_index table, :stm_labels
      add_index table, :stm_xfields  , :using => :gin
      add_index table, :stm_jfields  , :using => :gin
    end

    create_table :positions do |t|
      t.integer  :offer_id
      t.integer  :user_id
      t.integer  :amendment_id
      t.integer  :escrow_id
      t.integer  :parent_id
      t.integer  :volume
      t.float    :price
      t.float    :value
      t.string   :side            # 'fixed' or 'unfixed'
      t.string   :exref
      t.string   :uuref
      t.timestamps
    end
    add_index :positions, :offer_id
    add_index :positions, :user_id
    add_index :positions, :amendment_id
    add_index :positions, :escrow_id
    add_index :positions, :parent_id
    add_index :positions, :volume
    add_index :positions, :price
    add_index :positions, :value
    add_index :positions, :exref
    add_index :positions, :uuref
    add_index :positions, :side

    create_table :escrows do |t|
      t.string   :type
      t.integer  :sequence      # SORTABLE POSITION USING ACTS_AS_LIST
      t.integer  :contract_id
      t.integer  :amendment_id
      t.float    :fixed_value  ,     default: 0.0
      t.float    :unfixed_value,     default: 0.0
      t.string   :exref
      t.string   :uuref
      t.timestamps
    end
    add_index :escrows, :type
    add_index :escrows, :contract_id
    add_index :escrows, :amendment_id
    add_index :escrows, :sequence
    add_index :escrows, :exref
    add_index :escrows, :uuref

    create_table :amendments do |t|
      t.string   :type               # expand, transfer, reduce, resolve
      t.integer  :sequence           # SORTABLE POSITION USING ACTS_AS_LIST
      t.integer  :contract_id
      t.hstore   :xfields,  null: false, default: {}
      t.jsonb    :jfields,  null: false, default: {}
      t.string   :exref
      t.string   :uuref
      t.timestamps
    end
    add_index :amendments, :sequence
    add_index :amendments, :contract_id
    add_index :amendments, :xfields, using: :gin
    add_index :amendments, :jfields, using: :gin
    add_index :amendments, :exref
    add_index :amendments, :uuref

    create_table :users do |t|
      t.boolean  :admin
      t.float    :balance, default: 0.0
      t.string   :exref
      t.string   :uuref
      t.jsonb    :jfields , null: false, default: {}
      t.datetime :last_seen_at
      t.timestamps
    end
    add_index :users, :exref
    add_index :users, :uuref
    add_index :users, :jfields, using: :gin

    # the event store...
    create_table :events do |t|
      t.string     :type
      t.string     :uuref
      t.string     :cmd_type
      t.string     :cmd_id
      t.string     :local_hash
      t.string     :chain_hash
      t.jsonb      :data    , null: false, default: {}
      t.jsonb      :jfields , null: false, default: {}
      t.integer    :user_ids, array: true, default: []
      t.datetime   :projected_at
      t.timestamps
    end
    add_index :events, :type
    add_index :events, :uuref
    add_index :events, :cmd_type
    add_index :events, :cmd_id
    add_index :events, :local_hash
    add_index :events, :chain_hash
    add_index :events, :data      , using: :gin
    add_index :events, :jfields   , using: :gin
    add_index :events, :user_ids  , using: :gin
    add_index :events, :projected_at

    # holds an event counter for a projection
    create_table :projections do |t|
      t.string  :name
      t.integer :event_counter
      t.timestamps
    end
  end
end
