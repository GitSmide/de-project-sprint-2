INSERT INTO public.shipping_country_rates (shipping_country, shipping_country_base_rate)
SELECT DISTINCT shipping_country, shipping_country_base_rate
FROM public.shipping;

INSERT INTO public.shipping_agreement (agreement_id, agreement_number,
									agreement_rate, agreement_commission)
SELECT DISTINCT vad[1]::INT AS agreement_id, vad[2]::VARCHAR(12) AS agreement_number,
				vad[3]::NUMERIC(14,2) AS agreement_rate, vad[4]::NUMERIC(14,2) AS agreement_commission
FROM (
	SELECT regexp_split_to_array(vendor_agreement_description, ':+') AS vad
	FROM public.shipping
) AS f;

INSERT INTO public.shipping_transfer (transfer_type,
											transfer_model, shipping_transfer_rate)
SELECT DISTINCT std[1]::VARCHAR(2) AS transfer_type, std[2]::VARCHAR(10) AS transfer_model,
		shipping_transfer_rate
FROM (
	SELECT shipping_transfer_rate, regexp_split_to_array(shipping_transfer_description, ':+') AS std
	FROM public.shipping
) AS s;

INSERT INTO public.shipping_info (shipping_id, vendor_id, payment_amount,
							shipping_plan_datetime, shipping_transfer_id,
							shipping_agreement_id, shipping_country_rates_id)
SELECT  shippingid, vendorid, payment_amount,
							shipping_plan_datetime, st.id AS shipping_transfer_id,
							sa.agreement_id AS shipping_agreement_id, scr.id AS shipping_country_rates_id
FROM (SELECT DISTINCT shippingid, vendorid, payment_amount,
	shipping_plan_datetime, shipping_country,
	regexp_split_to_array(shipping_transfer_description, ':+') AS std,
	regexp_split_to_array(vendor_agreement_description, ':+') AS vad
	FROM public.shipping
) AS shipping_all 
JOIN public.shipping_transfer AS st ON shipping_all.std[2] = st.transfer_model AND shipping_all.std[1] = st.transfer_type
JOIN public.shipping_country_rates AS scr ON shipping_all.shipping_country = scr.shipping_country
JOIN public.shipping_agreement AS sa ON shipping_all.vad[1]::SMALLINT = sa.agreement_id;

INSERT INTO public.shipping_status (shipping_id, status, state,
						shipping_start_fact_datetime, shipping_end_fact_datetime)
WITH ti AS (
	SELECT shippingid, MIN(state_datetime) AS shipping_start_fact_datetime, MAX(state_datetime) AS shipping_end_fact_datetime 
	FROM public.shipping
	GROUP BY shippingid
)
SELECT ti.shippingid, status, state,
shipping_start_fact_datetime, shipping_end_fact_datetime 
FROM ti LEFT JOIN public.shipping AS s ON ti.shipping_end_fact_datetime=s.state_datetime;