DROP TABLE IF EXISTS public.shipping_country_rates;
DROP TABLE IF EXISTS public.shipping_agreement;
DROP TABLE IF EXISTS public.shipping_transfer;
DROP TABLE IF EXISTS public.shipping_info;
DROP TABLE IF EXISTS public.shipping_status;

CREATE TABLE public.shipping_country_rates
(
id SERIAL,
shipping_country VARCHAR(56),
shipping_country_base_rate NUMERIC(14,2),
CONSTRAINT scr_id_pkey PRIMARY KEY (id)
);

CREATE TABLE public.shipping_agreement
(
agreement_id SMALLINT,
agreement_number VARCHAR(12),
agreement_rate NUMERIC(14,2),
agreement_commission NUMERIC(14,2),
CONSTRAINT sa_agreement_id_pkey PRIMARY KEY (agreement_id)
);

CREATE TABLE public.shipping_transfer
(
id SERIAL,
transfer_type VARCHAR(2),
transfer_model VARCHAR(10),
shipping_transfer_rate NUMERIC(14,3),
CONSTRAINT st_id_pkey PRIMARY KEY (id)
);

CREATE TABLE public.shipping_info
(
shipping_id INT,
vendor_id SMALLINT,
payment_amount NUMERIC(14,2),
shipping_plan_datetime TIMESTAMP,
shipping_transfer_id SMALLINT,
shipping_agreement_id SMALLINT,
shipping_country_rates_id SMALLINT,
CONSTRAINT si_shipping_id_pkey PRIMARY KEY (shipping_id),
CONSTRAINT si_shipping_transfer_id_fkey FOREIGN KEY (shipping_transfer_id) REFERENCES shipping_transfer (id) ON UPDATE cascade,
CONSTRAINT si_shipping_agreement_id_fkey FOREIGN KEY (shipping_agreement_id) REFERENCES shipping_agreement (agreement_id) ON UPDATE cascade,
CONSTRAINT si_shipping_country_rates_id_fkey FOREIGN KEY (shipping_country_rates_id) REFERENCES shipping_country_rates (id) ON UPDATE cascade
);

CREATE TABLE public.shipping_status
(
shipping_id INT,
status VARCHAR(15),
state VARCHAR(15),
shipping_start_fact_datetime TIMESTAMP,
shipping_end_fact_datetime TIMESTAMP,
CONSTRAINT ss_shipping_id_pkey PRIMARY KEY (shipping_id)
);