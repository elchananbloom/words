
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:words/models/enums.dart';
// import 'package:words/models/word/word.dart';


// Provider<List<Word>> wordsProvider = Provider<List<Word>>((ref) => words);


// // list of 40 words with different sentences
// List<Word> words = <Word>[
//   Word(
//     word: <Language, String>{
//       Language.english: 'Hello',
//       Language.hebrew: 'שלום',
//       Language.hangul: '안녕하세요',
//     },
//     sentence: <Language, String>{
//       Language.english: 'Hello, how are you?',
//       Language.hebrew: 'שלום, מה שלומך?',
//       Language.hangul: '안녕하세요, 어떻게 지내세요?',
//     },
//     image: 'assets/images/hello.png',
//   ),
//   Word(
//     word: <Language, String>{
//       Language.english: 'Goodbye',
//       Language.hebrew: 'להתראות',
//       Language.hangul: '안녕히 가세요',
//     },
//     sentence: <Language, String>{
//       Language.english: 'Goodbye, see you later',
//       Language.hebrew: 'להתראות, נתראה מאוחר יותר',
//       Language.hangul: '안녕히 가세요, 나중에 봐요',
//     },
//     image: 'assets/images/goodbye.png',
//   ),
//   Word(
//     word: <Language, String>{
//       Language.english: 'Thank you',
//       Language.hebrew: 'תודה',
//       Language.hangul: '감사합니다',
//     },
//     sentence: <Language, String>{
//       Language.english: 'Thank you for your help',
//       Language.hebrew: 'תודה על העזרה שלך',
//       Language.hangul: '도움 주셔서 감사합니다',
//     },
//     image: 'assets/images/thankyou.png',
//   ),
//   Word(
//     word: <Language, String>{
//       Language.english: 'Please',
//       Language.hebrew: 'בבקשה',
//       Language.hangul: '제발',
//     },
//     sentence: <Language, String>{
//       Language.english: 'Please, can you help me?',
//       Language.hebrew: 'בבקשה, אתה יכול לעזור לי?',
//       Language.hangul: '제발, 도와주세요?',
//     },
//     image: 'assets/images/please.png',
//   ),
//   Word(
//     word: <Language, String>{
//       Language.english: 'Yes',
//       Language.hebrew: 'כן',
//       Language.hangul: '예',
//     },
//     sentence: <Language, String>{
//       Language.english: 'Yes, I can help you',
//       Language.hebrew: 'כן, אני יכול לעזור לך',
//       Language.hangul: '예, 도와 드릴 수 있어요',
//     },
//     image: 'assets/images/yes.png',
//   ),
//   Word(
//     word: <Language, String>{
//       Language.english: 'No',
//       Language.hebrew: 'לא',
//       Language.hangul: '아니요',
//     },
//     sentence: <Language, String>{
//       Language.english: 'No, I can\'t help you',
//       Language.hebrew: 'לא, אני לא יכול לעזור לך',
//       Language.hangul: '아니요, 도와 드릴 수 없어요',
//     },
//     image: 'assets/images/no.png',
//   ),
//   Word(
//     word: <Language, String>{
//       Language.english: 'Sorry',
//       Language.hebrew: 'מצטער',
//       Language.hangul: '미안해요',
//     },
//     sentence: <Language, String>{
//       Language.english: 'Sorry, I can\'t help you',
//       Language.hebrew: 'מצטער, אני לא יכול לעזור לך',
//       Language.hangul: '미안해요, 도와 드릴 수 없어요',
//     },
//     image: 'assets/images/sorry.png',
//   ),
//   Word(
//     word: <Language, String>{
//       Language.english: 'Excuse me',
//       Language.hebrew: 'סליחה',
//       Language.hangul: '실례합니다',
//     },
//     sentence: <Language, String>{
//       Language.english: 'Excuse me, can you help me?',
//       Language.hebrew: 'סליחה, אתה יכול לעזור לי?',
//       Language.hangul: '실례합니다, 도와주세요?',
//     },
//     image: 'assets/images/excuseme.png',
//   ),
//   Word(
//     word: <Language, String>{
//       Language.english: 'I',
//       Language.hebrew: 'אני',
//       Language.hangul: '나는',
//     },
//     sentence: <Language, String>{
//       Language.english: 'I am hungry',
//       Language.hebrew: 'אני רעב',
//       Language.hangul: '나는 배고파',
//     },
//     image: 'assets/images/i.png',
//   ),
//   Word(
//     word: <Language, String>{
//       Language.english: 'You',
//       Language.hebrew: 'אתה',
//       Language.hangul: '너는',
//     },
//     sentence: <Language, String>{
//       Language.english: 'You are hungry',
//       Language.hebrew: 'אתה רעב',
//       Language.hangul: '너는 배고파',
//     },
//     image: 'assets/images/you.png',
//   ),
//   Word(
//     word: <Language, String>{
//       Language.english: 'He',
//       Language.hebrew: 'הוא',
//       Language.hangul: '그는',
//     },
//     sentence: <Language, String>{
//       Language.english: 'He is hungry',
//       Language.hebrew: 'הוא רעב',
//       Language.hangul: '그는 배고파',
//     },
//     image: 'assets/images/he.png',
//   ),
//   Word(
//     word: <Language, String>{
//       Language.english: 'She',
//       Language.hebrew: 'היא',
//       Language.hangul: '그녀는',
//     },
//     sentence: <Language, String>{
//       Language.english: 'She is hungry',
//       Language.hebrew: 'היא רעבה',
//       Language.hangul: '그녀는 배고파',
//     },
//     image: 'assets/images/she.png',
//   ),
//   Word(
//     word: <Language, String>{
//       Language.english: 'We',
//       Language.hebrew: 'אנחנו',
//       Language.hangul: '우리는',
//     },
//     sentence: <Language, String>{
//       Language.english: 'We are hungry',
//       Language.hebrew: 'אנחנו רעבים',
//       Language.hangul: '우리는 배고파',
//     },
//     image: 'assets/images/we.png',
//   ),
//   Word(
//     word: <Language, String>{
//       Language.english: 'They',
//       Language.hebrew: 'הם',
//       Language.hangul: '그들은',
//     },
//     sentence: <Language, String>{
//       Language.english: 'They are hungry',
//       Language.hebrew: 'הם רעבים',
//       Language.hangul: '그들은 배고파',
//     },
//     image: 'assets/images/they.png',
//   ),
//   Word(
//     word: <Language, String>{
//       Language.english: 'What',
//       Language.hebrew: 'מה',
//       Language.hangul: '무엇',
//     },
//     sentence: <Language, String>{
//       Language.english: 'What is your name?',
//       Language.hebrew: 'מה שמך?',
//       Language.hangul: '당신의 이름은 무엇입니까?',
//     },
//     image: 'assets/images/what.png',
//   ),
//   Word(
//     word: <Language, String>{
//       Language.english: 'Where',
//       Language.hebrew: 'איפה',
//       Language.hangul: '어디',
//     },
//     sentence: <Language, String>{
//       Language.english: 'Where are you from?',
//       Language.hebrew: 'מאיפה אתה?',
//       Language.hangul: '당신은 어디에서 왔습니까?',
//     },
//     image: 'assets/images/where.png',
//   ),
//   Word(
//     word: <Language, String>{
//       Language.english: 'When',
//       Language.hebrew: 'מתי',
//       Language.hangul: '언제',
//     },
//     sentence: <Language, String>{
//       Language.english: 'When is your birthday?',
//       Language.hebrew: 'מתי יום ההולדת שלך?',
//       Language.hangul: '당신의 생일은 언제입니까?',
//     },
//     image: 'assets/images/when.png',
//   ),
// ];