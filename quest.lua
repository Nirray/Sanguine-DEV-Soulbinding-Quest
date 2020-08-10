quest drob_nirray_soulcatching begin
	state start begin
		-- Sanguine Soulcatching quest
		-- Autor: Nirray & BeHolder
		-- // 29.04.2019 // 
		-- https://www.quora.com/Do-longer-variable-names-make-a-program-slower
		-- Minimalny poziom umiejętności: 1
		-- Na maksymalnym poziomie jest 70% szans na złapanie potwora w marmurze
		when 102.kill with ((pc.get_wear(7) == 71011 or pc.get_wear(8) == 71011) and (pc.get_skill_level(160) >= 1 and pc.count_item(8001) >= 1)) begin
		--syschat(pc.get_skill_level(160))
		--syschat(pc.get_weapon())
		--syschat(pc.get_armor())
		-- Zabrane z source
		local c_Equipment_Body		= 0;
		local c_Equipment_Head		= 1;
		local c_Equipment_Shoes		= 2;
		local c_Equipment_Wrist		= 3;
		local c_Equipment_Weapon	= 4;
		local c_Equipment_Neck		= 5;
		local c_Equipment_Ear		= 6;
		local c_Equipment_Unique1	= 7;
		local c_Equipment_Unique2	= 8;
		local c_Equipment_Arrow		= 9;
		local c_Equipment_Shield	= 10;
		-- Szansa na wypadnięcie
		local generate_drop	= number(1, 100)
		--
		local drop_chance 				= 5
		local soulcatcher_set_armor		= 5
		local soulcatcher_set_weapon	= 15
		local soulcatcher_set_head		= 3
		local soulcatcher_set_shoes		= 2
		local soulcatcher_set_wrist		= 4
		local soulcatcher_set_neck		= 10 -- unikalny, ale coś czuję, że to będzie przegięcie
		local default_weapon_vnum		= 0
		local default_mana_usage		= 150
		syschat("##############")
		syschat("default_weapon_vnum = "..default_weapon_vnum)
		if (pc.job == 0) then
			default_weapon_vnum = 3004
			syschat("set default_weapon_vnum = "..default_weapon_vnum)
			end
		if (pc.job == 1) then
			default_weapon_vnum = 2004
			syschat("set default_weapon_vnum = "..default_weapon_vnum)
			end
		if (pc.job == 2) then
			default_weapon_vnum = 14
			syschat("set default_weapon_vnum = "..default_weapon_vnum)
			end
		if (pc.job == 3) then
			default_weapon_vnum = 5004
			syschat("set default_weapon_vnum = "..default_weapon_vnum)
			end
		-- maksymalnie: 34%, zmniejszenie obrażeń: -40% dla naszyjnika
		
		-- Zabranie 50 PE bez bransolety z zestawu przedmiotów
		if (pc.get_wear(c_Equipment_Wrist) != 14000) then
			if pc.getsp() >= default_mana_usage then
				pc.change_sp(-default_mana_usage)
				syschat("Kradziez PE: "..default_mana_usage)
			else
				syschat("[Informacja] Nie posiadasz odpowiedniej ilości PE.")
				return
			end
		end
		--
		if (pc.get_armor() == 11302) then
			drop_chance = drop_chance + soulcatcher_set_armor
			syschat("Soulcatcher armor: +5% droprate")
			end
		if (pc.get_weapon() == default_weapon_vnum) then
			-- system lanc byłby lepszy do tego questa, dlatego daję już local zmienną do czasu aż się namyślę
			drop_chance = drop_chance + soulcatcher_set_weapon
			syschat("Soulcatcher weapon: +15% droprate")
			end
		-- domyślnie 5% na rozpoczęcie eventu
		syschat("total droprate: "..drop_chance)
		if generate_drop <= drop_chance then
			pc.remove_item("8001", 1)
			syschat("[Informacja] Serce Bera pomyślnie spętało duszę potwora z zaświatów.")
			--syschat(generate_drop)
			local soul = mob.spawn(9001, pc.get_local_x(), pc.get_local_y(), number(1, 5), number(1, 5), 1)
			--target.npc("mob1", soul)
			-- Dodatkowy drop dla dwóch specjalnych przedmiotów z setu: zbroja i broń
			if (pc.get_armor() == 11302) then
				game.drop_item_with_ownership(70044, 1)
				end
			if (pc.get_weapon() == default_weapon_vnum) then
				game.drop_item_with_ownership(70042, 1)
				end
		else
			-- Niepowodzenie; usuwanie przedmiotu; poinformowanie gracza
			pc.remove_item("8001", 1)
			syschat("[Informacja] Serce Bera niepomyślnie spętało duszę potwora.")
			--syschat(generate_drop)
			end
		syschat("-------------------")
		end
		
		-- Zaklinanie npc w marmurze różowym
		when 9001.take with item.vnum == 70104 begin
			-- sprawdzanie "KD" w przedmiocie, które dla marmurów odpowiada jako ID npc
			if item.get_socket(0) > 0 then
				syschat("[Informacja] W tym marmurze brakuje już miejsca.")
				return
			end
			-- zawsze usuwa NPC przed wylosowaniem liczby, aby zmniejszyć szansę na wykorzystanie błędu gry
			npc.purge()
			local chance = number(1, 100)
			--[[
				1	2.333333333
				2	3.666666667
				3	5
				4	6.333333333
				5	7.666666667
				6	9
				7	10.33333333
				8	11.66666667
				9	13
				10	14.33333333
				11	15.66666667
				12	17
				13	18.33333333
				14	19.66666667
				15	21
				16	22.33333333
				17	23.66666667
				18	25
				19	26.33333333
				M1 - M10
				20	27.66666667 // 28%
				21	29
				22	30.33333333
				23	31.66666667
				24	33
				25	34.33333333
				26	35.66666667
				27	37
				28	38.33333333
				29	39.66666667
				G1 - G10
				30	41
				31	42.33333333
				32	43.66666667
				33	45
				34	46.33333333
				35	47.66666667
				36	49
				37	50.33333333
				38	51.66666667
				39	53
				P
				40	54.33333333 // 70%
				(3+(0*4)/3) = 1% ~ domyślnie
			]]
			local soul_catch_base_chance = (3+(pc.get_skill_level(160)*4))/3
			--syschat(chance)
			
			if pc.get_skill_level(160) < 20 then
				-- (3+(1*4)/)3 ~ 2.3 + 1.476 = 3.8
				-- Na 19 = 26%
				soul_catch_base_chance = soul_catch_base_chance+1.476
				end
			if pc.get_skill_level(160) == 20 then
				soul_catch_base_chance = 28 -- default: 27.666%
				end
			if pc.get_skill_level(160) == 40 then
				soul_catch_base_chance = 70 -- default: 54.333%
				--syschat("Skill na poziomie P, szansa 70%")
				end
			--syschat(soul_catch_base_chance)
			-- tradebug fix // BeHolder
			-- fix jest w 80% poprawny, niżej dodałem swoją wersje // Nirray
			if pc.count_item(70104) < 1 then
				syschat("[Informacja] Brak wymaganego przedmiotu.")
				return
			end
			-- // Nirray drugi fix
			syschat("-------------------")
			syschat("chance: "..chance)
			syschat("soul_catch_base_chance: "..soul_catch_base_chance)
			if (chance <= soul_catch_base_chance) and (pc.count_item(70104) != 0) then
			--[[
				Nieistotne, że może to być marmur z potworem w innym miejscu w ekwipunku, chodzi o sam fakt, 
				żeby nie zmieniał socketu w wynullowanym sockecie itemka w miejscu pustym funkcji ITEM_MANAGER::instance() w source.
				-->
				default :
					sys_err("POLYMORPH invalid item passed PID(%d) vnum(%d)", GetPlayerID(), item->GetOriginalVnum());
					return false; <<--
				if (item->GetSocket(1) = 0)
				{
					return false;
				}
				if (GetExchange() || GetMyShop() || GetShopOwner() || IsOpenSafebox() || IsCubeOpen())
					return false;
					
					// fixed
				W zasadzie quest nie zmieni kamienia w itemku, który właśnie przehandlowaliśmy; chodzi tylko o slot w eq; dodatkowo sprawdziłem to prostym kodem w pythonie do zmieniania położenia itemków w eq, błąd wizualny, nie da się za pomocą tej zmiany socket->slot zwiększyć np. czasu w PD jak to było na plikach 2k89, w source jest to zabezpieczone i zmodyfikowane przeze mnie :)
			]]
				item.set_socket(0, 9001)
				syschat("[Informacja] Pomyślnie zakląłeś duszę w marmurze.")
			else
				item.remove()
				syschat("[Informacja] Zaklinanie niepomyślne.")
				end
			
		end
	end
end
