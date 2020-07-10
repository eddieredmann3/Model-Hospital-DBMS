CREATE TABLE NURSE (
	N_SSN INT not null
    check((N_SSN > POWER(10,9)) AND (N_SSN < POWER(10,10))),
    F_Name varchar(45) not null, 
    L_Name varchar(45) not null,
    PhoneNumber INT not null
    check((PhoneNumber > POWER(10,10)) AND (PhoneNumber < Power(10,11))),
    Salary decimal(6,2) not null,
    primary key(N_SSN)
);

CREATE TABLE DOCTOR (
	D_SSN INT not null
    check((D_SSN > POWER(10,9)) AND (D_SSN < POWER(10,10))),
    F_Name varchar(45) not null,
    L_Name varchar(45) not null,
    Expertise varchar(45) not null,
    PhoneNumber INT not null
    check((PhoneNumber > POWER(10,10)) AND (PhoneNumber < Power(10,11))),
    Building varchar(45) not null, 
    Office INT not null,
    Salary Decimal(6,2) not null,
    Email varchar(45) not null,
    primary key(D_SSN)
);

CREATE TABLE COVERAGE (
	PolicyNumber INT not null,
    Provider varchar(45) not null,
    Owner_SSN INT not null
    check((Owner_SSN > POWER(10,9)) AND (Owner_SSN < POWER(10,10))),
    Phone_Number INT not null
    check((PhoneNumber > POWER(10,10)) AND (PhoneNumber < Power(10,11))),
    Address varchar(45),
    primary key(PolicyNumber),
    primary key(Provider)
);

CREATE TABLE APPOINTMENT (
	D_SSN INT not null
    check((D_SSN > POWER(10,9)) AND (D_SSN < POWER(10,10))),
    P_SSN INT not null
    check((P_SSN > POWER(10,9)) AND (P_SSN < POWER(10,10))), 
    Appt_Time varchar(8) not null,
    Cause_of_visit varchar(500) not null,
    Building varchar(45) not null,
    Room INT not null,
    primary key(D_SSN),
    primary key(P_SSN),
    primary key(Appt_time)
);

CREATE TABLE MEDICINE (
	Formal_name varchar(45) not null,
    Drug_use varchar(500), 
    Manufacturer varchar(45),
    Cost_per_dose decimal(5,2),
    Dosage_frequency INT,
    primary key(Formal_Name),
    primary key(Manufacturer)
);

CREATE TABLE PATIENT (
	P_SSN INT not null
    check((P_SSN > POWER(10,9)) AND (P_SSN < POWER(10,10))), 
    F_Name varchar(45) not null,
    L_Name varchar(45) not null,
    Phone_Number INT not null,
    GP varchar(45) not null,
    Policy_Number INT not null
);

CREATE TABLE PAYS (
	D_SSN INT not null
    check((D_SSN > POWER(10,9)) AND (D_SSN < POWER(10,10))),
    PolicyNumber INT not null, 
    Provider varchar(45) not null,
    CONSTRAINT D_SSN_FKEY
		foreign key(D_SSN)
        references DOCTOR(D_SSN),
	CONSTRAINT PN_FKEY
		FOREIGN KEY(PolicyNumber)
        REFERENCES COVERAGE(PolicyNumber),
	CONSTRAINT PROVIDER_FKEY
		FOREIGN KEY(Provider)
        references COVERAGE(Provider)
);

CREATE TABLE PRESCRIBES (
	D_SSN INT not null
    check((D_SSN > POWER(10,9)) AND (D_SSN < POWER(10,10))),
    Formal_name varchar(45) not null,
    Manufacturer varchar(45) not null,
    CONSTRAINT D_SSN_FKEY
		foreign key(D_SSN)
        references DOCTOR(D_SSN),
	CONSTRAINT FORMAL_NAME_FKEY
		foreign key(Formal_name)
        references MEDICINE(Formal_name),
	CONSTRAINT MANUFACTURER_FKEY
		foreign key(Manufacturer)
        references MEDICINE(Manufacturer)
);

CREATE TABLE TAKES(
	P_SSN INT not null,
    Formal_name varchar(45) not null,
    Manufacturer varchar(45) not null,
    Prescribed_by INT not null,
    CONSTRAINT P_SSN_FKey
		Foreign Key(P_SSN)
        References PATIENT(P_SSN),
	CONSTRAINT Prescribed_by_FKey
		Foreign Key(D_SSN)
        References DOCTOR(D_SSN),
	CONSTRAINT Formal_Name_FKey
		Foreign Key(Formal_name)
        References MEDICINE(Formal_name),
	CONSTRAINT MANUFACTURER_FKEY
		foreign key(Manufacturer)
        references MEDICINE(Manufacturer)
);

CREATE TABLE HAS (
	P_SSN INT not null, 
    PolicyNumber INT not null,
    Provider varchar(45) not null,
    CONSTRAINT P_SSN_FKey
		Foreign Key(P_SSN)
        References PATIENT(P_SSN),
	CONSTRAINT PolicyNumber_FKey
		Foreign Key(PolicyNumber)
        References COVERAGE(PolicyNumber),
	CONSTRAINT PROVIDER_FKEY
		FOREIGN KEY(Provider)
        references COVERAGE(Provider)
);

CREATE TABLE SEES (
	D_SSN INT not null,
    P_SSN INT not null,
    CONSTRAINT D_SSN_FKey
		Foreign Key(D_SSN)
        References DOCTOR(D_SSN),
	CONSTRAINT P_SSN_FKey
		Foreign Key(P_SSN)
        References PATIENT(P_SSN)
);

CREATE TABLE PATIENT_DOSAGE(
	P_SSN INT NOT NULL,
    CONSTRAINT P_SSN_FKEY
		FOREIGN KEY(P_SSN)
        REFERENCES PATIENT(P_SSN),
	FORMAL_MEDICINE_NAME varchar(45) not null,
    CONSTRAINT FMN_FKEY
		foreign key(Formal_Name)
        references MEDICINE(Formal_name),
	ADMINISTERED_BY INT NOT NULL
    check((ADMINISTERED_BY > POWER(10,9)) AND (ADMINISTERED_BY < POWER(10,10)))
);

DELIMITER $$
CREATE TRIGGER ADMIN_BY_CHECK
BEFORE UPDATE ON PATIENT_DOSAGE
FOR EACH ROW 
BEGIN
	DECLARE pd INT;
	set pd = PATIENT_DOSAGE.ADMINISTERED_BY;
	IF (NOT EXISTS (SELECT D.D_SSN, N.N_SSN FROM DOCTOR D, NURSE N WHERE D.D_SSN = pd OR N.N_SSN = pd)) THEN
	BEGIN
        DECLARE msg varchar(255);
		set msg = "Invalid credentials";
        signal sqlstate'45000' set message_text= msg;
	END IF;
END DELIMITER $$;

CREATE VIEW Doctor_Appt AS 
	SELECT P.F_NAME, P.L_NAME, D.F_NAME, D.L_NAME 
    FROM PATIENT P, DOCTOR D 
    WHERE APPOINTMENT.P_SSN = PATIENT.P_SSN;