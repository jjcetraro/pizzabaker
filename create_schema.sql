PGDMP                         y            pizza_baker    11.8    11.8 5    D           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                       false            E           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                       false            F           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                       false            G           1262    58788    pizza_baker    DATABASE     �   CREATE DATABASE pizza_baker WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'Spanish_Spain.1252' LC_CTYPE = 'Spanish_Spain.1252';
    DROP DATABASE pizza_baker;
             postgres    false            �            1255    58861    del_ingredient_detail(bigint)    FUNCTION     �   CREATE FUNCTION public.del_ingredient_detail(id bigint) RETURNS void
    LANGUAGE sql
    AS $_$
UPDATE ingredient_detail SET deleted=true WHERE id=$1;
$_$;
 7   DROP FUNCTION public.del_ingredient_detail(id bigint);
       public       postgres    false            �            1255    58860    del_supplier(bigint)    FUNCTION     �   CREATE FUNCTION public.del_supplier(id bigint) RETURNS void
    LANGUAGE sql
    AS $_$
UPDATE supplier SET deleted=true WHERE id=$1;
$_$;
 .   DROP FUNCTION public.del_supplier(id bigint);
       public       postgres    false            �            1255    58867     fetch_ingredient_detail(boolean)    FUNCTION     �  CREATE FUNCTION public.fetch_ingredient_detail(include_deleted boolean) RETURNS TABLE(id bigint, id_ingredient bigint, region character varying, id_supplier bigint, price double precision, quantity bigint, is_hidden boolean)
    LANGUAGE sql STABLE
    AS $$
SELECT id, id_ingredient, region, id_supplier, price, quantity, is_hidden FROM ingredient_detail WHERE include_deleted OR NOT deleted ORDER BY id;
$$;
 G   DROP FUNCTION public.fetch_ingredient_detail(include_deleted boolean);
       public       postgres    false            �            1255    58868    fetch_ingredients(boolean)    FUNCTION     �   CREATE FUNCTION public.fetch_ingredients(include_deleted boolean) RETURNS TABLE(id bigint, name character varying)
    LANGUAGE sql STABLE
    AS $$
SELECT id, name FROM ingredient WHERE include_deleted OR NOT deleted ORDER BY id;
$$;
 A   DROP FUNCTION public.fetch_ingredients(include_deleted boolean);
       public       postgres    false            �            1255    58871     fetch_order_ingredient_details()    FUNCTION       CREATE FUNCTION public.fetch_order_ingredient_details() RETURNS TABLE(id bigint, id_order bigint, id_ingredient_detail bigint, quantity bigint, price double precision)
    LANGUAGE sql STABLE
    AS $$
SELECT * FROM order_ingredient_detail ORDER BY id;
$$;
 7   DROP FUNCTION public.fetch_order_ingredient_details();
       public       postgres    false            �            1255    58870    fetch_orders(boolean)    FUNCTION     $  CREATE FUNCTION public.fetch_orders(include_deleted boolean) RETURNS TABLE(id bigint, datetime date, id_pizza bigint, pizza_price double precision)
    LANGUAGE sql STABLE
    AS $$
SELECT id, datetime, id_pizza, pizza_price FROM "order" WHERE include_deleted OR NOT deleted ORDER BY id;
$$;
 <   DROP FUNCTION public.fetch_orders(include_deleted boolean);
       public       postgres    false            �            1255    58863    fetch_pizzas()    FUNCTION     �   CREATE FUNCTION public.fetch_pizzas() RETURNS TABLE(id bigint, size bigint, price double precision)
    LANGUAGE sql STABLE
    AS $$
SELECT id, size, price FROM pizza;
$$;
 %   DROP FUNCTION public.fetch_pizzas();
       public       postgres    false            �            1255    67032    fetch_supplier_by_id(bigint)    FUNCTION       CREATE FUNCTION public.fetch_supplier_by_id(supplierid bigint) RETURNS TABLE(id bigint, name character varying, ingredients character varying, is_hidden boolean)
    LANGUAGE sql STABLE
    AS $$
SELECT id, name, ingredients, is_hidden FROM supplier WHERE id = supplierId;
$$;
 >   DROP FUNCTION public.fetch_supplier_by_id(supplierid bigint);
       public       postgres    false            �            1255    58866    fetch_suppliers(boolean)    FUNCTION     1  CREATE FUNCTION public.fetch_suppliers(include_deleted boolean) RETURNS TABLE(id bigint, name character varying, ingredients character varying, is_hidden boolean)
    LANGUAGE sql STABLE
    AS $$
SELECT id, name, ingredients, is_hidden FROM supplier WHERE include_deleted OR NOT deleted ORDER BY id;
$$;
 ?   DROP FUNCTION public.fetch_suppliers(include_deleted boolean);
       public       postgres    false            �            1255    58854 !   ins_ingredient(character varying)    FUNCTION     �   CREATE FUNCTION public.ins_ingredient(name character varying) RETURNS bigint
    LANGUAGE sql
    AS $_$
INSERT INTO ingredient(name, deleted) VALUES ($1, false)
RETURNING id;
$_$;
 =   DROP FUNCTION public.ins_ingredient(name character varying);
       public       postgres    false            �            1255    58855 [   ins_ingredient_detail(bigint, character varying, bigint, double precision, bigint, boolean)    FUNCTION     y  CREATE FUNCTION public.ins_ingredient_detail(id_ingredient bigint, region character varying, id_supplier bigint, price double precision, quantity bigint, is_hidden boolean) RETURNS bigint
    LANGUAGE sql
    AS $_$
INSERT INTO ingredient_detail(id_ingredient, region, id_supplier, price, quantity, is_hidden, deleted) VALUES ($1, $2, $3, $4, $5, $6, false)
RETURNING id;
$_$;
 �   DROP FUNCTION public.ins_ingredient_detail(id_ingredient bigint, region character varying, id_supplier bigint, price double precision, quantity bigint, is_hidden boolean);
       public       postgres    false            �            1255    58857 )   ins_order(date, bigint, double precision)    FUNCTION     �   CREATE FUNCTION public.ins_order(datetime date, id_pizza bigint, pizza_price double precision) RETURNS bigint
    LANGUAGE sql
    AS $_$
INSERT INTO "order"(datetime, id_pizza, pizza_price, deleted) VALUES ($1, $2, $3, false)
RETURNING id;
$_$;
 ^   DROP FUNCTION public.ins_order(datetime date, id_pizza bigint, pizza_price double precision);
       public       postgres    false            �            1255    58858 E   ins_order_ingredient_detail(bigint, bigint, bigint, double precision)    FUNCTION     5  CREATE FUNCTION public.ins_order_ingredient_detail(id_order bigint, id_ingredient_detail bigint, quantity bigint, price double precision) RETURNS bigint
    LANGUAGE sql
    AS $_$
INSERT INTO order_ingredient_detail(id_order, id_ingredient_detail, quantity, price) VALUES ($1, $2, $3, $4)
RETURNING id;
$_$;
 �   DROP FUNCTION public.ins_order_ingredient_detail(id_order bigint, id_ingredient_detail bigint, quantity bigint, price double precision);
       public       postgres    false            �            1255    58852 ;   ins_supplier(character varying, character varying, boolean)    FUNCTION       CREATE FUNCTION public.ins_supplier(name character varying, ingredients character varying, is_hidden boolean) RETURNS bigint
    LANGUAGE sql
    AS $_$INSERT INTO supplier(name, ingredients, is_hidden, deleted) VALUES ($1, $2, $3, false)
RETURNING id;
$_$;
 m   DROP FUNCTION public.ins_supplier(name character varying, ingredients character varying, is_hidden boolean);
       public       postgres    false            �            1255    67034 )   restock_ingredient_detail(bigint, bigint)    FUNCTION     �   CREATE FUNCTION public.restock_ingredient_detail(id bigint, qt bigint) RETURNS void
    LANGUAGE sql
    AS $_$
UPDATE ingredient_detail SET quantity=(quantity + $2) WHERE id=$1;
$_$;
 F   DROP FUNCTION public.restock_ingredient_detail(id bigint, qt bigint);
       public       postgres    false            �            1255    67036 )   upd_ingredient(bigint, character varying)    FUNCTION     �   CREATE FUNCTION public.upd_ingredient(id bigint, name character varying) RETURNS void
    LANGUAGE sql
    AS $_$
UPDATE ingredient SET name=$2 WHERE id=$1;
$_$;
 H   DROP FUNCTION public.upd_ingredient(id bigint, name character varying);
       public       postgres    false            �            1255    67035 B   upd_ingredient_detail(bigint, character varying, double precision)    FUNCTION     �   CREATE FUNCTION public.upd_ingredient_detail(id bigint, region character varying, price double precision) RETURNS void
    LANGUAGE sql
    AS $_$
UPDATE ingredient_detail SET region=$2, price=$3 WHERE id=$1;
$_$;
 i   DROP FUNCTION public.upd_ingredient_detail(id bigint, region character varying, price double precision);
       public       postgres    false            �            1255    58862 (   upd_ingredient_detail_visibility(bigint)    FUNCTION     �   CREATE FUNCTION public.upd_ingredient_detail_visibility(id bigint) RETURNS void
    LANGUAGE sql
    AS $_$
UPDATE ingredient_detail SET is_hidden=(not is_hidden) WHERE id=$1;
$_$;
 B   DROP FUNCTION public.upd_ingredient_detail_visibility(id bigint);
       public       postgres    false            �            1255    58859 C   upd_supplier(bigint, character varying, character varying, boolean)    FUNCTION     �   CREATE FUNCTION public.upd_supplier(id bigint, name character varying, ingredients character varying, is_hidden boolean) RETURNS void
    LANGUAGE sql
    AS $_$
UPDATE supplier SET name=$2, ingredients=$3, is_hidden=$4 WHERE id=$1;
$_$;
 x   DROP FUNCTION public.upd_supplier(id bigint, name character varying, ingredients character varying, is_hidden boolean);
       public       postgres    false            �            1259    58801 
   ingredient    TABLE     ~   CREATE TABLE public.ingredient (
    id bigint NOT NULL,
    name character varying NOT NULL,
    deleted boolean NOT NULL
);
    DROP TABLE public.ingredient;
       public         postgres    false            �            1259    58811    ingredient_detail    TABLE     .  CREATE TABLE public.ingredient_detail (
    id bigint NOT NULL,
    id_ingredient bigint NOT NULL,
    region character varying NOT NULL,
    id_supplier bigint NOT NULL,
    price double precision NOT NULL,
    quantity bigint NOT NULL,
    is_hidden boolean NOT NULL,
    deleted boolean NOT NULL
);
 %   DROP TABLE public.ingredient_detail;
       public         postgres    false            �            1259    58809    ingredient_detail_id_seq    SEQUENCE     �   ALTER TABLE public.ingredient_detail ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.ingredient_detail_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       postgres    false    201            �            1259    58799    ingredient_id_seq    SEQUENCE     �   ALTER TABLE public.ingredient ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.ingredient_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       postgres    false    199            �            1259    58828    order    TABLE     �   CREATE TABLE public."order" (
    id bigint NOT NULL,
    datetime date NOT NULL,
    id_pizza bigint NOT NULL,
    pizza_price double precision NOT NULL,
    deleted boolean NOT NULL
);
    DROP TABLE public."order";
       public         postgres    false            �            1259    58826    order_id_seq    SEQUENCE     �   ALTER TABLE public."order" ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.order_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       postgres    false    205            �            1259    58835    order_ingredient_detail    TABLE     �   CREATE TABLE public.order_ingredient_detail (
    id bigint NOT NULL,
    id_order bigint NOT NULL,
    id_ingredient_detail bigint NOT NULL,
    quantity bigint NOT NULL,
    price double precision NOT NULL
);
 +   DROP TABLE public.order_ingredient_detail;
       public         postgres    false            �            1259    58833    order_ingredient_detail_id_seq    SEQUENCE     �   ALTER TABLE public.order_ingredient_detail ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.order_ingredient_detail_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       postgres    false    207            �            1259    58821    pizza    TABLE     u   CREATE TABLE public.pizza (
    id bigint NOT NULL,
    size bigint NOT NULL,
    price double precision NOT NULL
);
    DROP TABLE public.pizza;
       public         postgres    false            �            1259    58819    pizza_id_seq    SEQUENCE     �   ALTER TABLE public.pizza ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.pizza_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       postgres    false    203            �            1259    58791    supplier    TABLE     �   CREATE TABLE public.supplier (
    id bigint NOT NULL,
    name character varying NOT NULL,
    ingredients character varying NOT NULL,
    is_hidden boolean NOT NULL,
    deleted boolean NOT NULL
);
    DROP TABLE public.supplier;
       public         postgres    false            �            1259    58789    supplier_id_seq    SEQUENCE     �   ALTER TABLE public.supplier ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.supplier_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       postgres    false    197            9          0    58801 
   ingredient 
   TABLE DATA               7   COPY public.ingredient (id, name, deleted) FROM stdin;
    public       postgres    false    199   ,I       ;          0    58811    ingredient_detail 
   TABLE DATA               x   COPY public.ingredient_detail (id, id_ingredient, region, id_supplier, price, quantity, is_hidden, deleted) FROM stdin;
    public       postgres    false    201   �I       ?          0    58828    order 
   TABLE DATA               O   COPY public."order" (id, datetime, id_pizza, pizza_price, deleted) FROM stdin;
    public       postgres    false    205   �J       A          0    58835    order_ingredient_detail 
   TABLE DATA               f   COPY public.order_ingredient_detail (id, id_order, id_ingredient_detail, quantity, price) FROM stdin;
    public       postgres    false    207   K       =          0    58821    pizza 
   TABLE DATA               0   COPY public.pizza (id, size, price) FROM stdin;
    public       postgres    false    203   �K       7          0    58791    supplier 
   TABLE DATA               M   COPY public.supplier (id, name, ingredients, is_hidden, deleted) FROM stdin;
    public       postgres    false    197   �K       H           0    0    ingredient_detail_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.ingredient_detail_id_seq', 33, true);
            public       postgres    false    200            I           0    0    ingredient_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.ingredient_id_seq', 15, true);
            public       postgres    false    198            J           0    0    order_id_seq    SEQUENCE SET     ;   SELECT pg_catalog.setval('public.order_id_seq', 12, true);
            public       postgres    false    204            K           0    0    order_ingredient_detail_id_seq    SEQUENCE SET     M   SELECT pg_catalog.setval('public.order_ingredient_detail_id_seq', 28, true);
            public       postgres    false    206            L           0    0    pizza_id_seq    SEQUENCE SET     :   SELECT pg_catalog.setval('public.pizza_id_seq', 3, true);
            public       postgres    false    202            M           0    0    supplier_id_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('public.supplier_id_seq', 13, true);
            public       postgres    false    196            �
           2606    58818 (   ingredient_detail ingredient_detail_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.ingredient_detail
    ADD CONSTRAINT ingredient_detail_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY public.ingredient_detail DROP CONSTRAINT ingredient_detail_pkey;
       public         postgres    false    201            �
           2606    58808    ingredient ingredient_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.ingredient
    ADD CONSTRAINT ingredient_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY public.ingredient DROP CONSTRAINT ingredient_pkey;
       public         postgres    false    199            �
           2606    58839 4   order_ingredient_detail order_ingredient_detail_pkey 
   CONSTRAINT     r   ALTER TABLE ONLY public.order_ingredient_detail
    ADD CONSTRAINT order_ingredient_detail_pkey PRIMARY KEY (id);
 ^   ALTER TABLE ONLY public.order_ingredient_detail DROP CONSTRAINT order_ingredient_detail_pkey;
       public         postgres    false    207            �
           2606    58832    order order_pkey 
   CONSTRAINT     P   ALTER TABLE ONLY public."order"
    ADD CONSTRAINT order_pkey PRIMARY KEY (id);
 <   ALTER TABLE ONLY public."order" DROP CONSTRAINT order_pkey;
       public         postgres    false    205            �
           2606    58825    pizza pizza_pkey 
   CONSTRAINT     N   ALTER TABLE ONLY public.pizza
    ADD CONSTRAINT pizza_pkey PRIMARY KEY (id);
 :   ALTER TABLE ONLY public.pizza DROP CONSTRAINT pizza_pkey;
       public         postgres    false    203            �
           2606    58798    supplier supplier_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.supplier
    ADD CONSTRAINT supplier_pkey PRIMARY KEY (id);
 @   ALTER TABLE ONLY public.supplier DROP CONSTRAINT supplier_pkey;
       public         postgres    false    197            9   e   x�˹@@����È})��Pjnd�If���T�;��ݥ�$6c��n��0:�+GC��R�%��&�$���(D}>�1�'��҆����蕹B��Zw      ;   +  x�m��n�0�g�a�ei�ڭ�(	H�"M��}O��#�Z���;ґ��x���!��ܕ/{�Хa&��L]+
��n�������VМs�P�N�x|��A'��|�X2l���Q�H(L����9��8��O��a�Ve�Yf!����'��2,�^��2�L�56A�Z����/��u��0:���V�$��Ʌ-/�b�::leV��a��b۶R2�ͺ�kQ-���](�Zc�=���<m�I-կ�-:-;���n)��Y�S�
���(��!hs�ܚJ2N�'��6M���      ?   0   x�3�4202�50"N#Nc�4.#d!cN��!���!PaW� G�
      A   `   x�m�� !C��0�V�s����4!-,�l�Z�gHP�,ڸ�B�2�{Ȳ��$<�L_s��u�h��,�+O'h��XȦCO���h�����-�#@      =   "   x�3�44�4�2�42�4�2�41�4����� .�]      7   �   x�}���0�g�)�	��{��R+f��\�IG����'
�%���F�`��Ҫ%OoY���$c����h��̚ݢ��+�W4&E����)Z��|�#NF� y������g4&Y�p��7�m�s&i8�     