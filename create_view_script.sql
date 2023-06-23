CREATE OR REPLACE VIEW shipping_datamart AS (
SELECT ss.shipping_id, vendor_id, transfer_type,
EXTRACT(DAY FROM (shipping_end_fact_datetime - shipping_start_fact_datetime)) AS full_day_at_shipping,
shipping_end_fact_datetime > shipping_plan_datetime AS is_delay,
CASE
	WHEN status = 'finished' THEN 1
	ELSE 0
END::bool AS is_shipping_finish,
CASE
	WHEN shipping_end_fact_datetime > shipping_plan_datetime THEN 
	EXTRACT(DAY FROM (shipping_end_fact_datetime - shipping_plan_datetime))
	ELSE 0
END AS delay_day_at_shipping,
payment_amount, -- в задании есть, а на схеме данного столбца нет
payment_amount * (shipping_country_base_rate + agreement_rate + shipping_transfer_rate) as vat,
payment_amount * agreement_commission AS profit
FROM public.shipping_status AS ss JOIN public.shipping_info AS si ON ss.shipping_id=si.shipping_id
LEFT JOIN public.shipping_transfer AS sf ON si.shipping_transfer_id=sf.id
LEFT JOIN public.shipping_agreement AS sa ON sa.agreement_id=si.shipping_agreement_id
LEFT JOIN public.shipping_country_rates AS scr ON scr.id=si.shipping_country_rates_id
);