-- Delete all existing records
DELETE FROM dbo.MaintenanceLogs;

-- Add InspectionDate column if it does not exist (run only once)
-- ALTER TABLE dbo.MaintenanceLogs ADD InspectionDate DATE;

-- Insert 50 new records with InspectionDate
INSERT INTO dbo.MaintenanceLogs (LogID, TailNumber, Status, Component, PartHours, Details, InspectionDate) VALUES (2001, 'N100AA', 'AOG', 'Engine', 1500, 'Engine oil leak detected, immediate repair required.', '2026-01-10');
INSERT INTO dbo.MaintenanceLogs (LogID, TailNumber, Status, Component, PartHours, Details, InspectionDate) VALUES (2002, 'N101BB', 'In-Work', 'Landing Gear', 800, 'Landing gear strut replacement underway.', '2026-01-12');
INSERT INTO dbo.MaintenanceLogs (LogID, TailNumber, Status, Component, PartHours, Details, InspectionDate) VALUES (2003, 'N102CC', 'Serviceable', 'Avionics', 2300, 'Routine avionics check completed.', '2026-01-15');
INSERT INTO dbo.MaintenanceLogs (LogID, TailNumber, Status, Component, PartHours, Details, InspectionDate) VALUES (2004, 'N103DD', 'AOG', 'Fuel System', 1800, 'Fuel pump failure, awaiting new part.', '2026-01-18');
INSERT INTO dbo.MaintenanceLogs (LogID, TailNumber, Status, Component, PartHours, Details, InspectionDate) VALUES (2005, 'N104EE', 'In-Work', 'Brakes', 600, 'Brake pads worn, replacement in progress.', '2026-01-20');
INSERT INTO dbo.MaintenanceLogs (LogID, TailNumber, Status, Component, PartHours, Details, InspectionDate) VALUES (2006, 'N105FF', 'Serviceable', 'Navigation', 1200, 'Navigation system recalibrated.', '2026-01-22');
INSERT INTO dbo.MaintenanceLogs (LogID, TailNumber, Status, Component, PartHours, Details, InspectionDate) VALUES (2007, 'N106GG', 'AOG', 'Hydraulics', 1700, 'Hydraulic line rupture, repair scheduled.', '2026-01-25');
INSERT INTO dbo.MaintenanceLogs (LogID, TailNumber, Status, Component, PartHours, Details, InspectionDate) VALUES (2008, 'N107HH', 'In-Work', 'Electrical', 950, 'Alternator output low, diagnostics underway.', '2026-01-28');
INSERT INTO dbo.MaintenanceLogs (LogID, TailNumber, Status, Component, PartHours, Details, InspectionDate) VALUES (2009, 'N108II', 'Serviceable', 'Cabin', 2100, 'Cabin air filter replaced.', '2026-02-01');
INSERT INTO dbo.MaintenanceLogs (LogID, TailNumber, Status, Component, PartHours, Details, InspectionDate) VALUES (2010, 'N109JJ', 'AOG', 'Propeller', 400, 'Propeller blade crack detected.', '2026-02-03');
INSERT INTO dbo.MaintenanceLogs (LogID, TailNumber, Status, Component, PartHours, Details, InspectionDate) VALUES (2011, 'N110KK', 'In-Work', 'Engine', 1550, 'Engine vibration, balancing in progress.', '2026-02-05');
INSERT INTO dbo.MaintenanceLogs (LogID, TailNumber, Status, Component, PartHours, Details, InspectionDate) VALUES (2012, 'N111LL', 'Serviceable', 'Landing Gear', 850, 'Landing gear inspection passed.', '2026-02-07');
INSERT INTO dbo.MaintenanceLogs (LogID, TailNumber, Status, Component, PartHours, Details, InspectionDate) VALUES (2013, 'N112MM', 'AOG', 'Avionics', 2400, 'Transponder failure, replacement ordered.', '2026-02-09');
INSERT INTO dbo.MaintenanceLogs (LogID, TailNumber, Status, Component, PartHours, Details, InspectionDate) VALUES (2014, 'N113NN', 'In-Work', 'Fuel System', 1850, 'Fuel line blockage, cleaning underway.', '2026-02-11');
INSERT INTO dbo.MaintenanceLogs (LogID, TailNumber, Status, Component, PartHours, Details, InspectionDate) VALUES (2015, 'N114OO', 'Serviceable', 'Brakes', 650, 'Brake system inspection completed.', '2026-02-13');
INSERT INTO dbo.MaintenanceLogs (LogID, TailNumber, Status, Component, PartHours, Details, InspectionDate) VALUES (2016, 'N115PP', 'AOG', 'Navigation', 1250, 'Autopilot malfunction, troubleshooting required.', '2026-02-15');
INSERT INTO dbo.MaintenanceLogs (LogID, TailNumber, Status, Component, PartHours, Details, InspectionDate) VALUES (2017, 'N116QQ', 'In-Work', 'Hydraulics', 1750, 'Hydraulic pump replacement in progress.', '2026-02-17');
INSERT INTO dbo.MaintenanceLogs (LogID, TailNumber, Status, Component, PartHours, Details, InspectionDate) VALUES (2018, 'N117RR', 'Serviceable', 'Electrical', 1050, 'Wiring harness replaced.', '2026-02-19');
INSERT INTO dbo.MaintenanceLogs (LogID, TailNumber, Status, Component, PartHours, Details, InspectionDate) VALUES (2019, 'N118SS', 'AOG', 'Cabin', 2200, 'Cabin pressurization failure, inspection scheduled.', '2026-02-21');
INSERT INTO dbo.MaintenanceLogs (LogID, TailNumber, Status, Component, PartHours, Details, InspectionDate) VALUES (2020, 'N119TT', 'In-Work', 'Propeller', 450, 'Propeller balancing in progress.', '2026-02-23');
INSERT INTO dbo.MaintenanceLogs (LogID, TailNumber, Status, Component, PartHours, Details, InspectionDate) VALUES (2021, 'N120UU', 'Serviceable', 'Engine', 1600, 'Engine oil changed.', '2026-02-25');
INSERT INTO dbo.MaintenanceLogs (LogID, TailNumber, Status, Component, PartHours, Details, InspectionDate) VALUES (2022, 'N121VV', 'AOG', 'Landing Gear', 900, 'Landing gear actuator jammed.', '2026-02-27');
INSERT INTO dbo.MaintenanceLogs (LogID, TailNumber, Status, Component, PartHours, Details, InspectionDate) VALUES (2023, 'N122WW', 'In-Work', 'Avionics', 2500, 'Navigation display flickering, repair underway.', '2026-03-01');
INSERT INTO dbo.MaintenanceLogs (LogID, TailNumber, Status, Component, PartHours, Details, InspectionDate) VALUES (2024, 'N123XX', 'Serviceable', 'Fuel System', 1900, 'Fuel filter replaced.', '2026-03-03');
INSERT INTO dbo.MaintenanceLogs (LogID, TailNumber, Status, Component, PartHours, Details, InspectionDate) VALUES (2025, 'N124YY', 'AOG', 'Brakes', 700, 'Brake line leak detected.', '2026-03-05');
INSERT INTO dbo.MaintenanceLogs (LogID, TailNumber, Status, Component, PartHours, Details, InspectionDate) VALUES (2026, 'N125ZZ', 'In-Work', 'Navigation', 1300, 'Compass calibration in progress.', '2026-03-07');
INSERT INTO dbo.MaintenanceLogs (LogID, TailNumber, Status, Component, PartHours, Details, InspectionDate) VALUES (2027, 'N126AA', 'Serviceable', 'Hydraulics', 1800, 'Hydraulic system topped up.', '2026-03-09');
INSERT INTO dbo.MaintenanceLogs (LogID, TailNumber, Status, Component, PartHours, Details, InspectionDate) VALUES (2028, 'N127BB', 'AOG', 'Electrical', 1100, 'Battery failure, replacement ordered.', '2026-03-11');
INSERT INTO dbo.MaintenanceLogs (LogID, TailNumber, Status, Component, PartHours, Details, InspectionDate) VALUES (2029, 'N128CC', 'In-Work', 'Cabin', 2250, 'Cabin temperature sensor faulty.', '2026-03-13');
INSERT INTO dbo.MaintenanceLogs (LogID, TailNumber, Status, Component, PartHours, Details, InspectionDate) VALUES (2030, 'N129DD', 'Serviceable', 'Propeller', 500, 'Propeller spinner replaced.', '2026-03-15');
INSERT INTO dbo.MaintenanceLogs (LogID, TailNumber, Status, Component, PartHours, Details, InspectionDate) VALUES (2031, 'N130EE', 'AOG', 'Engine', 1650, 'Cylinder head crack detected.', '2026-03-17');
INSERT INTO dbo.MaintenanceLogs (LogID, TailNumber, Status, Component, PartHours, Details, InspectionDate) VALUES (2032, 'N131FF', 'In-Work', 'Landing Gear', 950, 'Landing gear door misaligned.', '2026-03-19');
INSERT INTO dbo.MaintenanceLogs (LogID, TailNumber, Status, Component, PartHours, Details, InspectionDate) VALUES (2033, 'N132GG', 'Serviceable', 'Avionics', 2600, 'Radio system tested, all clear.', '2026-03-21');
INSERT INTO dbo.MaintenanceLogs (LogID, TailNumber, Status, Component, PartHours, Details, InspectionDate) VALUES (2034, 'N133HH', 'AOG', 'Fuel System', 2000, 'Fuel tank vent blocked.', '2026-03-23');
INSERT INTO dbo.MaintenanceLogs (LogID, TailNumber, Status, Component, PartHours, Details, InspectionDate) VALUES (2035, 'N134II', 'In-Work', 'Brakes', 750, 'Brake caliper replacement underway.', '2026-03-25');
INSERT INTO dbo.MaintenanceLogs (LogID, TailNumber, Status, Component, PartHours, Details, InspectionDate) VALUES (2036, 'N135JJ', 'Serviceable', 'Navigation', 1350, 'Navigation lights replaced.', '2026-03-27');
INSERT INTO dbo.MaintenanceLogs (LogID, TailNumber, Status, Component, PartHours, Details, InspectionDate) VALUES (2037, 'N136KK', 'AOG', 'Hydraulics', 1850, 'Hydraulic accumulator failure.', '2026-03-29');
INSERT INTO dbo.MaintenanceLogs (LogID, TailNumber, Status, Component, PartHours, Details, InspectionDate) VALUES (2038, 'N137LL', 'In-Work', 'Electrical', 1150, 'Generator output low, testing.', '2026-03-31');
INSERT INTO dbo.MaintenanceLogs (LogID, TailNumber, Status, Component, PartHours, Details, InspectionDate) VALUES (2039, 'N138MM', 'Serviceable', 'Cabin', 2300, 'Cabin door seal replaced.', '2026-04-02');
INSERT INTO dbo.MaintenanceLogs (LogID, TailNumber, Status, Component, PartHours, Details, InspectionDate) VALUES (2040, 'N139NN', 'AOG', 'Propeller', 550, 'Propeller pitch control failure.', '2026-04-04');
INSERT INTO dbo.MaintenanceLogs (LogID, TailNumber, Status, Component, PartHours, Details, InspectionDate) VALUES (2041, 'N140OO', 'In-Work', 'Engine', 1700, 'Engine mount bolts loose, tightening.', '2026-04-06');
INSERT INTO dbo.MaintenanceLogs (LogID, TailNumber, Status, Component, PartHours, Details, InspectionDate) VALUES (2042, 'N141PP', 'Serviceable', 'Landing Gear', 1000, 'Landing gear lubrication completed.', '2026-04-08');
INSERT INTO dbo.MaintenanceLogs (LogID, TailNumber, Status, Component, PartHours, Details, InspectionDate) VALUES (2043, 'N142QQ', 'AOG', 'Avionics', 2700, 'Altitude encoder malfunction.', '2026-04-10');
INSERT INTO dbo.MaintenanceLogs (LogID, TailNumber, Status, Component, PartHours, Details, InspectionDate) VALUES (2044, 'N143RR', 'In-Work', 'Fuel System', 2050, 'Fuel selector valve replacement.', '2026-04-12');
INSERT INTO dbo.MaintenanceLogs (LogID, TailNumber, Status, Component, PartHours, Details, InspectionDate) VALUES (2045, 'N144SS', 'Serviceable', 'Brakes', 800, 'Brake system flushed.', '2026-04-14');
INSERT INTO dbo.MaintenanceLogs (LogID, TailNumber, Status, Component, PartHours, Details, InspectionDate) VALUES (2046, 'N145TT', 'AOG', 'Navigation', 1400, 'Navigation display failure.', '2026-04-16');
INSERT INTO dbo.MaintenanceLogs (LogID, TailNumber, Status, Component, PartHours, Details, InspectionDate) VALUES (2047, 'N146UU', 'In-Work', 'Hydraulics', 1900, 'Hydraulic fluid contaminated, flushing.', '2026-04-18');
INSERT INTO dbo.MaintenanceLogs (LogID, TailNumber, Status, Component, PartHours, Details, InspectionDate) VALUES (2048, 'N147VV', 'Serviceable', 'Electrical', 1200, 'Circuit breaker replaced.', '2026-04-20');
INSERT INTO dbo.MaintenanceLogs (LogID, TailNumber, Status, Component, PartHours, Details, InspectionDate) VALUES (2049, 'N148WW', 'AOG', 'Cabin', 2350, 'Cabin window cracked.', '2026-04-22');
INSERT INTO dbo.MaintenanceLogs (LogID, TailNumber, Status, Component, PartHours, Details, InspectionDate) VALUES (2050, 'N149XX', 'In-Work', 'Propeller', 600, 'Propeller spinner loose, tightening.', '2026-04-24');