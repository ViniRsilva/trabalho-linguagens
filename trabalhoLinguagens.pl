% ============================================================================
% SISTEMA DE GERENCIAMENTO DE BIBLIOTECA PESSOAL
% ============================================================================
% Grupo:
% - Vinicius Silva
% - Gabriel Domingues
% - Fernando Gazzana
% - Julia Tietbohl
% ============================================================================

% ============================================================================
% 1. BASE DE CONHECIMENTO - FATOS
% ============================================================================

% Declaracao de predicados dinamicos (permitem modificacao em tempo de execucao)
:- dynamic livro/4.
:- dynamic autor/2.
:- dynamic pessoa/2.
:- dynamic emprestado/3.

% Predicado: livro(Titulo, Autor, Ano, Categoria)
% Define informacoes sobre livros da biblioteca
livro('A Arte da Guerra', 'Sun Tzu', -500, 'Estrategia').
livro('O Codigo Limpo', 'Robert C. Martin', 2008, 'Tecnologia').
livro('1984', 'George Orwell', 1949, 'Ficcao').
livro('Sapiens', 'Yuval Noah Harari', 2011, 'Historia').
livro('O Principe', 'Niccolo Machiavelli', 1532, 'Filosofia').
livro('Clean Architecture', 'Robert C. Martin', 2017, 'Tecnologia').
livro('Dom Casmurro', 'Machado de Assis', 1899, 'Literatura').

% Predicado: autor(Nome, Nacionalidade)
% Define informacoes sobre autores
autor('Sun Tzu', 'Chinesa').
autor('Robert C. Martin', 'Americana').
autor('George Orwell', 'Britanica').
autor('Yuval Noah Harari', 'Israelense').
autor('Niccolo Machiavelli', 'Italiana').
autor('Machado de Assis', 'Brasileira').

% Predicado: pessoa(Nome, Identificador)
% Define pessoas que podem pegar livros emprestados
pessoa('Maria Silva', 101).
pessoa('Joao Santos', 102).
pessoa('Ana Costa', 103).
pessoa('Pedro Oliveira', 104).

% Predicado: emprestado(Titulo, IdentificadorPessoa, DataEmprestimo)
% Registra emprestimos de livros
emprestado('O Codigo Limpo', 102, '2025-10-20').
emprestado('Sapiens', 101, '2025-10-18').
emprestado('1984', 103, '2025-10-22').

% ============================================================================
% 2. REGRAS - CONSULTAS
% ============================================================================

% Regra: livros_por_autor(Autor, Titulo)
% Retorna todos os titulos escritos por um determinado autor
livros_por_autor(Autor, Titulo) :-
    livro(Titulo, Autor, _, _).

% Regra: livros_antigos(AnoMaximo, Titulo)
% Retorna todos os titulos publicados antes ou no ano especificado
livros_antigos(AnoMaximo, Titulo) :-
    livro(Titulo, _, Ano, _),
    Ano =< AnoMaximo.

% Regra: disponivel(Titulo)
% Verifica se um livro esta disponivel (nao emprestado)
disponivel(Titulo) :-
    livro(Titulo, _, _, _),
    \+ emprestado(Titulo, _, _).

% Regra: livros_emprestados_por(NomePessoa, Titulo)
% Retorna os titulos dos livros emprestados por uma pessoa
livros_emprestados_por(NomePessoa, Titulo) :-
    pessoa(NomePessoa, Id),
    emprestado(Titulo, Id, _).

% ============================================================================
% 3. REGRAS - OPERACOES DE ATUALIZACAO
% ============================================================================

% Regra: inserir_livro(Titulo, Autor, Ano, Categoria)
% Insere um novo livro na base de conhecimento
inserir_livro(Titulo, Autor, Ano, Categoria) :-
    \+ livro(Titulo, _, _, _),
    assertz(livro(Titulo, Autor, Ano, Categoria)),
    write('Livro "'), write(Titulo), write('" inserido com sucesso!'), nl.

inserir_livro(Titulo, _, _, _) :-
    livro(Titulo, _, _, _),
    write('Erro: Livro "'), write(Titulo), write('" ja existe na biblioteca!'), nl,
    fail.

% Regra: emprestar_livro(Titulo, NomePessoa, Data)
% Registra o emprestimo de um livro para uma pessoa
emprestar_livro(Titulo, NomePessoa, Data) :-
    livro(Titulo, _, _, _),
    pessoa(NomePessoa, Id),
    disponivel(Titulo),
    assertz(emprestado(Titulo, Id, Data)),
    write('Livro "'), write(Titulo), write('" emprestado para '),
    write(NomePessoa), write(' em '), write(Data), nl.

emprestar_livro(Titulo, NomePessoa, _) :-
    livro(Titulo, _, _, _),
    pessoa(NomePessoa, _),
    \+ disponivel(Titulo),
    write('Erro: Livro "'), write(Titulo), write('" ja esta emprestado!'), nl,
    fail.

emprestar_livro(Titulo, _, _) :-
    \+ livro(Titulo, _, _, _),
    write('Erro: Livro "'), write(Titulo), write('" nao existe na biblioteca!'), nl,
    fail.

emprestar_livro(_, NomePessoa, _) :-
    \+ pessoa(NomePessoa, _),
    write('Erro: Pessoa "'), write(NomePessoa), write('" nao esta cadastrada!'), nl,
    fail.

% Regra: devolver_livro(Titulo)
% Remove o registro de emprestimo de um livro (devolucao)
devolver_livro(Titulo) :-
    emprestado(Titulo, Id, Data),
    retract(emprestado(Titulo, Id, Data)),
    write('Livro "'), write(Titulo), write('" devolvido com sucesso!'), nl.

devolver_livro(Titulo) :-
    livro(Titulo, _, _, _),
    \+ emprestado(Titulo, _, _),
    write('Erro: Livro "'), write(Titulo), write('" nao esta emprestado!'), nl,
    fail.

devolver_livro(Titulo) :-
    \+ livro(Titulo, _, _, _),
    write('Erro: Livro "'), write(Titulo), write('" nao existe na biblioteca!'), nl,
    fail.

% ============================================================================
% 4. PREDICADOS AUXILIARES
% ============================================================================

% Regra: comparar_strings_insensivel(String1, String2)
% Compara duas strings ignorando maiusculas/minusculas
comparar_strings_insensivel(S1, S2) :-
    atom_string(S1, Str1),
    atom_string(S2, Str2),
    string_lower(Str1, Lower1),
    string_lower(Str2, Lower2),
    Lower1 = Lower2.

% Regra: listar_todos_livros
% Lista todos os livros da biblioteca
listar_todos_livros :-
    write('=== LIVROS NA BIBLIOTECA ==='), nl,
    livro(Titulo, Autor, Ano, Categoria),
    write('- '), write(Titulo), write(' ('), write(Autor), write(', '),
    write(Ano), write(') - '), write(Categoria), nl,
    fail.
listar_todos_livros.

% Regra: listar_emprestimos
% Lista todos os emprestimos ativos
listar_emprestimos :-
    write('=== EMPRESTIMOS ATIVOS ==='), nl,
    emprestado(Titulo, Id, Data),
    pessoa(Nome, Id),
    write('- '), write(Titulo), write(' -> '), write(Nome),
    write(' ('), write(Data), write(')'), nl,
    fail.
listar_emprestimos.

% Regra: listar_disponiveis
% Lista todos os livros disponiveis
listar_disponiveis :-
    write('=== LIVROS DISPONIVEIS ==='), nl,
    disponivel(Titulo),
    write('- '), write(Titulo), nl,
    fail.
listar_disponiveis.

% ============================================================================
% 5. BONUS - INTERFACE DE USUARIO terminal
% ============================================================================

% Predicado principal: menu
% Inicia a interface interativa do sistema
menu :-
    repeat,
    nl,
    write('========================================'), nl,
    write('   SISTEMA DE BIBLIOTECA PESSOAL'), nl,
    write('========================================'), nl,
    write('1. Listar todos os livros'), nl,
    write('2. Listar livros disponiveis'), nl,
    write('3. Listar emprestimos ativos'), nl,
    write('4. Buscar livros por autor'), nl,
    write('5. Buscar livros antigos'), nl,
    write('6. Verificar disponibilidade'), nl,
    write('7. Consultar emprestimos de pessoa'), nl,
    write('8. Inserir novo livro'), nl,
    write('9. Emprestar livro'), nl,
    write('10. Devolver livro'), nl,
    write('0. Sair'), nl,
    write('========================================'), nl,
    write('Escolha uma opcao: '),
    read(Opcao),
    processar_opcao(Opcao),
    Opcao =:= 0, !.

% Processa a opcao escolhida pelo usuario
processar_opcao(0) :-
    nl, write('Encerrando sistema... Ate logo!'), nl, !.

processar_opcao(1) :-
    nl, listar_todos_livros, nl, !.

processar_opcao(2) :-
    nl, listar_disponiveis, nl, !.

processar_opcao(3) :-
    nl, listar_emprestimos, nl, !.

processar_opcao(4) :-
    nl, write('Digite o nome do autor: '),
    read(AutorInput),
    nl, write('=== LIVROS DO AUTOR ==='), nl,
    (   livro(Titulo, Autor, _, _),
        comparar_strings_insensivel(AutorInput, Autor),
        write('- '), write(Titulo), nl,
        fail
    ;   true
    ), nl, !.

processar_opcao(5) :-
    nl, write('Digite o ano maximo: '),
    read(Ano),
    nl, write('=== LIVROS ANTIGOS ==='), nl,
    (   livros_antigos(Ano, Titulo),
        write('- '), write(Titulo), nl,
        fail
    ;   true
    ), nl, !.

processar_opcao(6) :-
    nl, write('Digite o titulo do livro: '),
    read(TituloInput),
    nl,
    (   livro(TituloReal, _, _, _),
        comparar_strings_insensivel(TituloInput, TituloReal),
        (   disponivel(TituloReal) ->
            write('Livro "'), write(TituloReal), write('" esta DISPONIVEL!'), nl
        ;   write('Livro "'), write(TituloReal), write('" esta EMPRESTADO!'), nl
        )
    ;   write('Livro "'), write(TituloInput), write('" nao existe na biblioteca!'), nl
    ), nl, !.

processar_opcao(7) :-
    nl, write('Digite o nome da pessoa: '),
    read(NomeInput),
    nl, write('=== EMPRESTIMOS DE '), write(NomeInput), write(' ==='), nl,
    (   pessoa(NomeReal, Id),
        comparar_strings_insensivel(NomeInput, NomeReal),
        emprestado(Titulo, Id, _),
        write('- '), write(Titulo), nl,
        fail
    ;   true
    ), nl, !.

processar_opcao(8) :-
    nl, write('Digite o titulo do livro: '),
    read(Titulo),
    write('Digite o nome do autor: '),
    read(Autor),
    write('Digite o ano de publicacao: '),
    read(Ano),
    write('Digite a categoria: '),
    read(Categoria),
    nl,
    (   livro(TituloExistente, _, _, _),
        comparar_strings_insensivel(Titulo, TituloExistente) ->
        write('Erro: Livro "'), write(TituloExistente), write('" ja existe na biblioteca!'), nl
    ;   assertz(livro(Titulo, Autor, Ano, Categoria)),
        write('Livro "'), write(Titulo), write('" inserido com sucesso!'), nl
    ), nl, !.

processar_opcao(9) :-
    nl, write('Digite o titulo do livro: '),
    read(TituloInput),
    write('Digite o nome da pessoa: '),
    read(NomeInput),
    write('Digite a data (formato: \'AAAA-MM-DD\'): '),
    read(Data),
    nl,
    (   livro(TituloReal, _, _, _),
        comparar_strings_insensivel(TituloInput, TituloReal),
        pessoa(NomeReal, Id),
        comparar_strings_insensivel(NomeInput, NomeReal),
        (   disponivel(TituloReal) ->
            assertz(emprestado(TituloReal, Id, Data)),
            write('Livro "'), write(TituloReal), write('" emprestado para '),
            write(NomeReal), write(' em '), write(Data), nl
        ;   write('Erro: Livro "'), write(TituloReal), write('" ja esta emprestado!'), nl
        )
    ;   \+ (livro(T, _, _, _), comparar_strings_insensivel(TituloInput, T)) ->
        write('Erro: Livro "'), write(TituloInput), write('" nao existe na biblioteca!'), nl
    ;   write('Erro: Pessoa "'), write(NomeInput), write('" nao esta cadastrada!'), nl
    ), nl, !.

processar_opcao(10) :-
    nl, write('Digite o titulo do livro: '),
    read(TituloInput),
    nl,
    (   emprestado(TituloReal, Id, Data),
        comparar_strings_insensivel(TituloInput, TituloReal),
        retract(emprestado(TituloReal, Id, Data)),
        write('Livro "'), write(TituloReal), write('" devolvido com sucesso!'), nl
    ;   livro(TituloReal, _, _, _),
        comparar_strings_insensivel(TituloInput, TituloReal),
        \+ emprestado(TituloReal, _, _),
        write('Erro: Livro "'), write(TituloReal), write('" nao esta emprestado!'), nl
    ;   write('Erro: Livro "'), write(TituloInput), write('" nao existe na biblioteca!'), nl
    ), nl, !.

processar_opcao(_) :-
    nl, write('Opcao invalida! Tente novamente.'), nl, !.

% ============================================================================
% 6. EXEMPLOS DE CONSULTAS -> 
% CONSULTAS PRECISAM SEGUIR O FORMATO: 
% se -> pessoa('Joao Santos', 102).
% entao -> 7. Consultar emprestimos de pessoa
% Digite o nome da pessoa: 
% 'Joao Santos'
% ============================================================================
% Para interface (SWI-Prolog):
% ?- menu.
%
% Para testes individuais:
% ?- livros_por_autor('Robert C. Martin', Titulo).
% ?- livros_antigos(2000, Titulo).
% ?- disponivel('A Arte da Guerra').
% ?- livros_emprestados_por('Maria Silva', Titulo).
% ?- inserir_livro('O Hobbit', 'J.R.R. Tolkien', 1937, 'Fantasia').
% ?- emprestar_livro('A Arte da Guerra', 'Pedro Oliveira', '2025-10-23').
% ?- devolver_livro('Sapiens').
% ============================================================================
