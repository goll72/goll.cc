
const allQuizes : HTMLElement[] = document.querySelectorAll(".quiz-question");


for(let quiz of allQuizes){
	const choices : HTMLElement = quiz.getElementsByTagName("input");
	let singleChoice : boolean = false;
	let name : string;

	if(quiz.classList.contains("single-choice")){
		name = quiz.getAttribute("id");
		singleChoice = true;
	}

	const correct : boolean[] = [];
	for(let choice of choices){
		correct.push(choice.checked);
			
		if(singleChoice){
			choice.setAttribute("type", "radio");
			choice.setAttribute("name", name);
		}

		choice.checked = false;
	}

	const answerBlocks : HTMLElement[] = quiz.querySelectorAll(".answer");
	for(let ansBlk of answerBlocks){
		ansBlk.hidden = true;
	}

	let button : HTMLElement = document.createElement("button");

	if(singleChoice){
		button.textContent = "Verificar resposta";
	}
	else{
		button.textContent = "Verificar respostas";
	}

	button.addEventListener("click", () => {
		button.disabled = true;
		button.value = "Disabled";
		checkQuiz(quiz, singleChoice, correct);
	})

	quiz.appendChild(button);
}

function checkQuiz(quiz : HTMLElement, singleChoice : boolean, correct : boolean[]): void {
	const choices : HTMLElements[] = quiz.getElementsByTagName("input");

	for(let i = 0; i < choices.length; i++){
		// An answer will be marked green, in a single choice quiz,
		// if it is simply the correct one, or, in a multiple choice one,
		// if it is marked. It will be marked red if it was incorrect but was
		// selected. The ones that were not selected and also were not correct
		// will be left the original color.

		if(correct[i] != choices[i].checked){
			if(singleChoice && correct[i]){
				choices[i].parentElement.style.color = "green";
			}
			else{
				choices[i].parentElement.style.color = "red";
			}

			quiz.querySelector(`#answer${i}`).hidden = false;
		}

		else if(correct[i]){
			choices[i].parentElement.style.color = "green";
		}
	}

}
