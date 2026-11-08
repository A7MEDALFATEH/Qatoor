class_name JourneyStoryData
extends RefCounted
## Narrative data is separate from scenes, ready for future recorded Arabic voice-over.
## A dialogue entry may optionally add a "voice" res:// audio path.

const STAGES: Dictionary = {
	"reservoir": {
		"title": "A little drop.\nA remarkable journey.",
		"title_ar": "رحلة قطرة النفط",
		"eyebrow": "01 / A WORLD BENEATH OUR FEET",
		"description": "Meet Qatoor, an oil drop with a very big dream. Your adventure begins inside the connected pores of reservoir rock.",
		"dialogue": "مرحباً أصدقائي! أنا قطّور، أعيش داخل مسامات الصخور في مكمن نفطي عميق. أريد أن أرى العالم فوق سطح الأرض! هل تساعدونني؟",
		"fact": "Oil occupies connected rock pores. A reservoir is not an underground lake.",
		"dialogues": [
			"مرحباً أصدقائي! أنا قطّور، قطرة نفط صغيرة أعيش منذ ملايين السنين في أعماق الأرض!",
			"أنا داخل مسامات الصخور، ولست في بحيرة تحت الأرض! أحتاج إلى بئر حتى أبدأ رحلتي."
		]
	},
	"drilling": {
		"title": "Make a way\nto the reservoir.",
		"title_ar": "لنحفر طريقاً إلى المكمن",
		"eyebrow": "02 / DRILLING & COMPLETION",
		"description": "Bring the rig to life. Watch the bit cut rock while drilling fluid carries cuttings back to the surface.",
		"dialogue": "هيا نبدأ الحفر! يدور رأس الحفر وتعود فتات الصخور مع سائل الحفر. بعد الوصول، نجهّز البئر وأنبوب الإنتاج قبل تدفق النفط.",
		"fact": "Drilling creates a wellbore; completion adds the equipment and tubing needed for production.",
		"complete_dialogue": "رائع! وصلنا إلى المكمن. والآن اكتمل تجهيز البئر وأصبح مسار الإنتاج جاهزاً!",
		"dialogues": [
			"ساعدوني على الوصول إلى المكمن! زيادة السرعة هنا تسرّع العرض فقط، ولا تتنبأ بسرعة الحفر الحقيقية.",
			"رائع! وصلنا إلى المكمن. نركّب الآن تجهيزات البئر وأنبوب الإنتاج حتى يصبح المسار جاهزاً."
		]
	},
	"pressure": {
		"title": "A little opening.\nA powerful difference.",
		"title_ar": "فرق الضغط يبدأ الرحلة",
		"eyebrow": "03 / THE PRESSURE CHALLENGE",
		"description": "Open the choke and watch Qatoor move. Pressure difference drives oil from the reservoir into the well.",
		"dialogue": "افتحوا مسار الإنتاج! فرق الضغط بين المكمن وقاع البئر يساعد النفط على التحرك. فتح الخانق لا يخفض ضغط المكمن كله فوراً.",
		"fact": "Natural production needs enough pressure to overcome hydrostatic head, friction and receiving pressure.",
		"no_flow_dialogue": "الضغط المتاح لا يكفي للتغلب على عمود السائل وفواقد الجريان. قد يحتاج هذا البئر إلى رفع اصطناعي!",
		"dialogues": [
			"حين يكون الخانق مغلقاً، يتوقف الإنتاج. جرّبوا فتحه جزئياً ثم أكثر، وراقبوا حركة النفط!",
			"ممتاز! فرق الضغط يساعدنا على التحرك نحو البئر، بينما يبقى ضغط المكمن ثابتاً في مثالنا التعليمي."
		]
	},
	"race": {
		"title": "Next stop:\nthe world above.",
		"title_ar": "السباق الكبير نحو السطح",
		"eyebrow": "04 / UP THE PRODUCTION TUBING",
		"description": "Ride upward with Qatoor. Adjust the choke, change the framing, and meet Ghazi as the local pressure falls.",
		"dialogue": "واااو! أنا أصعد داخل أنبوب الإنتاج! غيّروا فتحة الخانق لتشاهدوا أثرها على الحركة. سيظهر غازي إذا انخفض الضغط عن ضغط الفقاعة.",
		"fact": "Free gas may evolve when local oil pressure falls below its bubble-point pressure.",
		"gas_dialogue": "مرحباً! أنا غازي، فقاعة غاز! ظهرت لأن الضغط المحلي انخفض دون ضغط الفقاعة في هذا المثال التعليمي.",
		"dialogues": [
			"واااو! أنا أصعد الآن داخل البئر! هل ترون كيف تتغيّر حركة النفط مع فتحة الخانق؟",
			"أنا غازي! قد يتحرّر الغاز من النفط عندما ينخفض الضغط المحلي دون ضغط الفقاعة، حسب خصائص النفط."
		]
	},
	"separator": {
		"title": "Three friends.\nThree different exits.",
		"title_ar": "نفط وغاز وماء",
		"eyebrow": "05 / THE THREE-PHASE SEPARATOR",
		"description": "Help Qatoor, Ghazi and Maee find the right outlet. Gas rises; oil and water settle into separate liquid layers.",
		"dialogue": "وصلنا إلى السطح! علينا فصل النفط عن الغاز والماء. الغاز في الأعلى، والنفط فوق الماء لأنه أقل كثافة منه في مثالنا. اختاروا المخرج الصحيح لكل صديق!",
		"fact": "A separator splits gas, oil and water into phases. It does not refine crude oil.",
		"hints": {
			"oil": "Oil is the middle liquid layer: above the denser water and below the gas.",
			"gas": "Gas rises into the space at the top of the vessel.",
			"water": "Water is denser than oil here, so it settles in the bottom layer."
		},
		"dialogues": [
			"ساعدوني في اختيار مخرج النفط! أنا أطفو فوق الماء داخل الفاصل.",
			"غازي يرتفع إلى أعلى الوعاء، ومائي يستقر في القاع. هذا فصل للمراحل، وليس تكريراً للنفط."
		]
	},
	"refinery": {
		"title": "One resource.\nSo many possibilities.",
		"title_ar": "من النفط إلى حياتنا اليومية",
		"eyebrow": "06 / REFINING & EVERYDAY MATERIALS",
		"description": "Explore five destinations. Refineries separate and process crude; petrochemical plants turn selected feedstocks into materials.",
		"dialogue": "رحلتي لم تنتهِ بعد! تعالج المصافي النفط لتنتج أنواعاً من الوقود والمواد الأولية. وتحوّل مصانع البتروكيماويات بعض هذه المواد عبر مراحل صناعية إلى البلاستيك.",
		"fact": "Refining and petrochemical manufacturing are different industrial stages.",
		"products": {
			"car": {"title": "Fuel for the road", "caption": "Refining → fuel distribution → refuelling → transport", "dialogue": "بعد التكرير والمعالجة، يُنقل وقود السيارات إلى محطات التعبئة. انظروا، سيارتنا جاهزة للانطلاق!"},
			"marine": {"title": "Across the oceans", "caption": "Refining & fuel specifications → bunkering → marine engines", "dialogue": "تستخدم سفن كثيرة وقوداً مشتقاً من النفط بعد التكرير والمعالجة ومطابقة المواصفات. يُزوَّد الوقود في الميناء لتشغيل المحركات البحرية؛ ولا يُستخدم النفط الخام مباشرة. تختلف أنواع الوقود باختلاف المحرك واللوائح البيئية."},
			"aviation": {"title": "Ready for take-off", "caption": "Refining & specification checks → airport supply → aircraft", "dialogue": "وقود الطائرات يُكرَّر ويُعالَج ليلائم مواصفات دقيقة، ثم يُنقل إلى المطار. هيا نحو السماء!"},
			"plastic": {"title": "A new material takes shape", "caption": "Petroleum feedstock → petrochemical processing → polymers → moulding", "dialogue": "النفط لا يتحول مباشرة إلى بلاستيك! نحتاج إلى مواد أولية بتروكيماوية، ثم عمليات صناعية وبلمرة وتشكيل لصناعة المنتج."},
			"asphalt": {"title": "Building the road ahead", "caption": "Refinery bitumen → mixing with aggregate → paving", "dialogue": "يُخلَط البيتومين الناتج من معالجة بعض أنواع النفط مع الركام لصناعة الخلطة الإسفلتية. ها هي الطريق تظهر أمامنا!"}
		},
		"dialogues": [
			"هل تعلمون أن النفط يدخل في صناعة أشياء نستخدمها يومياً؟ اختاروا منتجاً لنكتشف طريقه!",
			"تُكرّر المصافي النفط، وتُصنع بعض المواد لاحقاً في مصانع البتروكيماويات. لكل منتج رحلته الصناعية."
		]
	},
	"finale": {
		"title": "You made\nthe journey happen.",
		"title_ar": "شكراً لكم يا أصدقاء قطّور",
		"eyebrow": "07 / FROM DEEP BELOW TO EVERYDAY LIFE",
		"description": "From connected pores to the well, separator and refinery: a remarkable journey, made possible by engineering and your choices.",
		"dialogue": "شكراً لكم! ساعدتموني في رحلتي من أعماق الأرض إلى سطحها. والآن تعرفون كيف يساهم مهندسو النفط في إيصال الطاقة والمواد المهمة إلى حياتنا!",
		"fact": "Explore again, watch the cinematic presentation, or put your new knowledge to the test.",
		"dialogues": [
			"شكراً لكم! لقد ساعدتموني في رحلتي من أعماق الأرض إلى سطحها!",
			"والآن تعرفون كيف يساهم مهندسو النفط في إيصال الطاقة والمواد المهمة إلى حياتنا!"
		]
	}
}

const QUIZ: Array[Dictionary] = [
	{
		"prompt": "Where does Qatoor live underground?",
		"prompt_ar": "أين يعيش قطّور تحت الأرض؟",
		"answers": ["Connected pores in reservoir rock", "A huge underground oil lake", "Inside the drilling rig"],
		"answers_ar": ["في مسامات الصخور المتصلة", "في بحيرة نفط تحت الأرض", "داخل برج الحفر"],
		"correct": 0,
		"explanation": "Reservoir oil occupies connected pore spaces between rock grains.",
		"explanation_ar": "يشغل النفط مسامات متصلة بين حبيبات صخور المكمن."
	},
	{
		"prompt": "What drives oil from the reservoir into the well?",
		"prompt_ar": "ما الذي يدفع النفط من المكمن إلى البئر؟",
		"answers": ["The colour of the drilling mud", "A sufficient pressure difference", "A valve that instantly empties reservoir pressure"],
		"answers_ar": ["لون سائل الحفر", "فرق ضغط كافٍ", "صمام يخفض ضغط المكمن كله فوراً"],
		"correct": 1,
		"explanation": "Pressure must overcome the fluid column, receiving pressure and flow losses.",
		"explanation_ar": "يجب أن يتغلب الضغط على عمود السائل وضغط الاستقبال وفواقد الجريان."
	},
	{
		"prompt": "What does a three-phase separator do?",
		"prompt_ar": "ماذا يفعل الفاصل ثلاثي الأطوار؟",
		"answers": ["Turns crude directly into plastic", "Produces finished petrol", "Separates oil, gas and water"],
		"answers_ar": ["يحوّل النفط مباشرة إلى بلاستيك", "ينتج بنزيناً جاهزاً", "يفصل النفط والغاز والماء"],
		"correct": 2,
		"explanation": "Separation comes before refining. Plastic requires later petrochemical processing.",
		"explanation_ar": "الفصل يسبق التكرير، وتتطلب صناعة البلاستيك عمليات بتروكيماوية لاحقة."
	}
]
