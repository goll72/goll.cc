const registers : string[] = ["zero", "ra", "sp", "gp", "tp", "t0", "t1", "t2", "s0", "s1", "a0", "a1", "a2", "a3", "a4", "a5", "a6", "a7", "s2", "s3", "s4", "s5", "s6", "s7", "s8", "s9", "s10", "s11", "t3", "t4", "t5", "t6"];

const asmDiv = document.querySelector("#asmDiv");

const playground : NodeListOf<HTMLElement> = asmDiv.querySelectorAll(".playground")

for (let step of playground) {
	const id : string = step.getAttribute("id");

	if (id == "instruction"){
		const choices = step.querySelectorAll("input");

		for (let i = 0; i < choices.length; i++) {
			choices[i].setAttribute("type", "radio");
			choices[i].setAttribute("name", id);
			choices[i].value = i;

			choices[i].addEventListener("change", chInstrucType)
		}
		
		if(id == "instruction"){

			const button : HTMLButtonElement = document.createElement("button");

			button.textContent = "Gerar resultado";

			button.addEventListener("click", makeAsm);
			step.appendChild(button);
		}

	}
	else if (id == "branch") {
		step.hidden = true;

		const choices = step.querySelectorAll("input");

		for (let i = 0; i < choices.length; i++) {
			choices[i].setAttribute("type", "radio");
			choices[i].setAttribute("name", id);
			choices[i].value = `${i}`;
		}

	}
	else if (id == "register") {
		const rd = step.querySelector("#rd");
		const rdSelector = document.createElement("select");
		rdSelector.setAttribute("id", "rdSelector");
		
		const rs1 = step.querySelector("#rs1");
		const rs1Selector = document.createElement("select");
		rs1Selector.setAttribute("id", "rs1Selector");
		
		const rs2 = step.querySelector("#rs2");
		const rs2Selector = document.createElement("select");
		rs2Selector.setAttribute("id", "rs2Selector");

		for (let i = 0; i < registers.length; i++) {
			let regOption = document.createElement("option");
			regOption.value = i;
			regOption.text = registers[i];

			if (i == 3 || i == 4) {
				continue; // nao quero que os registradores gp e tp possam ser utilizados
			}

			rs1Selector.appendChild(regOption);
			rs2Selector.appendChild(regOption.cloneNode(true));

			if (i < 2) {
				continue; // nao quero que zero e ra possam ser modificados
			}

			rdSelector.appendChild(regOption.cloneNode(true));
		}
		
		rd.appendChild(rdSelector);
		rs1.appendChild(rs1Selector);
		rs2.appendChild(rs2Selector);

	}
	else if (id == "immediate") {
		step.hidden = true;
		const numIn = document.createElement("input");
		numIn.setAttribute("type", "number");
		numIn.setAttribute("placeholder", "Immediate");
		numIn.setAttribute("value", "0");
		step.appendChild(numIn);
		// mensagem de erro no caso de numero fora do range
		const pErr = document.createElement("p");
		pErr.style.color = "red";
		pErr.setAttribute("id", "immErr");
		pErr.hidden = true;
		step.appendChild(pErr);
	}
}


function chInstrucType(e) {
	const instrucDiv = asmDiv.querySelector("#instruction");

	const instrucType : number = Number(instrucDiv.querySelector("input:checked").value);
	// values:	0 -> load
	//			1 -> store
	//			2 -> add
	//			3 -> add immediate
	//			4 -> branch
	
	if (instrucType == 4) {
		asmDiv.querySelector("#branch").hidden = false;
		asmDiv.querySelector("#immediate").querySelector("p").innerText = "Escolha o número de instruções a serem puladas (se nenhum for colocado, zero é o padrão):"
	}
	else{
		asmDiv.querySelector("#branch").hidden = true;
		asmDiv.querySelector("#immediate").querySelector("p").innerText = "Escolha um valor imediato (se nenhum for colocado, zero é o padrão):"
	}

	const registerDiv = asmDiv.querySelector("#register");

	if(instrucType == 1 || instrucType == 4){
		asmDiv.querySelector("#rd").parentElement.parentElement.hidden = true;
	}
	else{
		asmDiv.querySelector("#rd").parentElement.parentElement.hidden = false;
	}


	if(instrucType == 0 || instrucType == 3){
		asmDiv.querySelector("#rs2").parentElement.parentElement.hidden = true;
	}
	else{
		asmDiv.querySelector("#rs2").parentElement.parentElement.hidden = false;
	}

	if(instrucType == 2){
		asmDiv.querySelector("#immediate").hidden = true;
	}
	else{
		asmDiv.querySelector("#immediate").hidden = false;
	}

}

function makeAsm(e){
	const instrucDiv = asmDiv.querySelector("#instruction");

	const instrucType : number = Number(instrucDiv.querySelector("input:checked").value);
	// values:	0 -> load
	//			1 -> store
	//			2 -> add
	//			3 -> add immediate
	//			4 -> branch

	let branchType : number = -1;
	if (instrucType == 4) {
		const branchDiv = asmDiv.querySelector("#branch");
		branchType = Number(branchDiv.querySelector("input:checked").value);
	}

	const registerDiv = asmDiv.querySelector("#register");
	let rdValue = -1;
	let rs1Value = -1;
	let rs2Value = -1;

	if(instrucType != 1 && instrucType != 4) {
		rdValue = Number(asmDiv.querySelector("#rdSelector").value)
	}

	rs1Value = Number(asmDiv.querySelector("#rs1Selector").value);

	if(instrucType != 0 && instrucType != 3) {
		rs2Value = Number(asmDiv.querySelector("#rs2Selector").value);
	}


	let immediate = 0;
	if(instrucType != 2){
		const immDiv = asmDiv.querySelector("#immediate");
		const pErr = immDiv.querySelector("p#immErr");
		immediate = Number(immDiv.querySelector("input").value);

		// teste de erro: se o immediate é maior que o numero de bits permite
		if(instrucType == 4 && (immediate > 1023 || immediate < -1024)){
			pErr.innerText = "Erro! Deve ser digitado um número entre 1023 e -1024."
			pErr.hidden = false;
			return;
		}
		else if(immediate > 2047 || immediate < -2048){
			pErr.innerText = "Erro! Deve ser digitado um número entre 2047 e -2048."
			pErr.hidden = false;
			return;
		}
		else{
			pErr.hidden = true;
		}
	}

	const codes = asmDiv.querySelector("#result").querySelectorAll("code");
	const assembly = codes[0];
	const binario = codes[1];

	switch(instrucType){
		case 0: // load
			assembly.innerText = `Assembly: lb ${registers[rdValue]}, ${immediate}(${registers[rs1Value]})`;

			binario.innerText = `Binário: ${binRep(immediate, 12, 0)} | ${binRep(rs1Value, 5, 0)} | 000 | ${binRep(rdValue, 5, 0)} | 0000011\n` +
								`          immediate      rs1    f3*     rd     opcode`
			break;
		case 1: // store
			assembly.innerText = `Assembly: sb ${registers[rs2Value]}, ${immediate}(${registers[rs1Value]})`;

			binario.innerText = `Binário: ${binRep(immediate, 12, 5)} | ${binRep(rs2Value, 5, 0)} | ${binRep(rs1Value, 5, 0)} | 000 | ${binRep(immediate, 5, 0)} | 0100011\n` +
								`       imm[11:5]    rs2     rs1    f3*  imm[4:0]  opcode`
			break;
		case 2: // add
			assembly.innerText = `Assembly: add ${registers[rdValue]}, ${registers[rs1Value]}, ${registers[rs2Value]}`;

			binario.innerText = `Binário: 0000000 | ${binRep(rs2Value, 5, 0)} | ${binRep(rs1Value, 5, 0)} | 000 | ${binRep(rdValue, 5, 0)} | 0110011\n` +
								`          funct7    rs2     rs1    f3*     rd     opcode`
			break;
		case 3: // add immediate
			assembly.innerText = `Assembly: addi ${registers[rdValue]}, ${registers[rs1Value]}, ${immediate}`;

			binario.innerText = `Binário: ${binRep(immediate, 12, 0)} | ${binRep(rs1Value, 5, 0)} | 000 | ${binRep(rdValue, 5, 0)} | 0010011\n` +
								`           immediate     rs1    f3*     rd     opcode`
			break;
		case 4: // branch

			immediate = immediate * 4; // uma instrução são 4 bytes
			const imm : string[] = new Array(4);
			imm[0] = binRep(immediate, 13, 12);
			imm[1] = binRep(immediate, 11, 5);
			imm[2] = binRep(immediate, 5, 1);
			imm[3] = binRep(immediate, 12, 11);

			let instrucStr : string = "b";
			let funct3 : string;

			switch(branchType) {
				case(0):
					instrucStr += "eq";
					funct3 = "000";
					break;
				case(1):
					instrucStr += "ne";
					funct3 = "001";
					break;
				case(2):
					instrucStr += "lt";
					funct3 = "100";
					break;
				case(3):
					instrucStr += "ge";
					funct3 = "101";
					break;

			}
			assembly.innerText = `Assembly: ${instrucStr} ${registers[rs1Value]}, ${registers[rs2Value]}, ${immediate}`;

			binario.innerText = `Binário: ${imm[0]} | ${imm[1]} | ${binRep(rs2Value, 5, 0)} | ${binRep(rs1Value, 5, 0)} | ${funct3} | ${imm[2]} | ${imm[3]} | 110001\n` +
								`    imm[12]  imm[10:5]  rs2   rs1   f3*  imm[4:1] imm[11]  opcode`
			break;
	}
}


function binRep(num : number, end : number, start : number): string {
	let binaryWhole = (num >>> 0).toString(2).padStart(end, "0");
	return binaryWhole.substring(binaryWhole.length - end, binaryWhole.length - start);
}
