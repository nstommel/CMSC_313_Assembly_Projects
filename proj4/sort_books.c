
/* Project 4
 * File: sort_books.c
 * Author: Nick Stommel
 * CMSC 313, Park Section 02
 * Edited 04/05/17
 * Description: Program reads from input fields to create array of book structs.
 * Then, books are sorted first by year, then if years are the same by title. 
 * Selection sort is used in conjunction with bookcmp assembly comparison function 
 * to sort the books
 */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

/* Field lengths */
#define TITLE_LEN       32
#define AUTHOR_LEN      20
#define SUBJECT_LEN     10

/* Declaration of book struct */
struct book {
    char author[AUTHOR_LEN + 1];    /* first author */
    char title[TITLE_LEN + 1];
    char subject[SUBJECT_LEN + 1];  /* Nonfiction, Fantasy, Mystery, ... */
    unsigned int year;              /* year of e-book release */
};

/* Declarations for functions that are defined in other files */
extern int bookcmp(void);

/* Declarations for global variables accessed from other files */
struct book *book1, *book2;

#define MAX_BOOKS 100

/* Forward declare print_books and sort_books functions */
void print_books(struct book books[], int numBooks);
void sort_books(struct book books[], int numBooks);


int main(int argc, char **argv) {
    
    struct book books[MAX_BOOKS];
    int numBooks, i;
    
    for (i = 0; i < MAX_BOOKS; i++) {
        /* Sample line: "Breaking Point, Pamela Clare, Romance, 2011" */

        /* Note that for the string fields, it uses the conversion spec
         * "%##[^,]", where "##" is an actual number. This says to read up to
         * a maximum of ## characters (not counting the null terminator!),
         * stopping at the first ','  We have left it up to you to finish
         * out the scanf() call by suppying the remaining arguments specifying
         * where scanf should put the data.  They should be mostly pointers
         * to the fields within the book struct you are filling, e.g.,
         * "&(books[i].year)".  However, note that the first field spec--
         * the title field--specifies 80 chars.  The title field in the
         * struct book is NOT that large, so you need to read it into a
         * temporary buffer first, of an appropriately large size so that
         * scanf() doesn't overrun it.  Again, all the other fields can
         * be read directly into the struct book's members.
         */
        char titlebuf[81];
        int numFields = scanf("%80[^,], %20[^,], %10[^,], %u \n",
                      titlebuf, books[i].author, books[i].subject, &books[i].year);
        
        if (numFields == EOF) {
            numBooks = i;
            if(numBooks == 0) {
                printf("Error, no books in file present\n");
                exit(1);
            }            
            break;
        }

        /* Now, process the record you just read.
         * First, confirm that you got all the fields you needed (scanf()
         * returns the actual number of fields matched).
         * Then, post-process title (see project spec for reason)
         */
        if(numFields != 4) {
            printf("Error, four fields required per entry\n");
            exit(1);
        }
        /* copy at max 32 characters from buffer into book field */
        strncpy(books[i].title, titlebuf, 32);
    }

    /* number of books read stored in var numBooks */
    sort_books(books, numBooks);

    print_books(books, numBooks);

    return 0;
}


/*
 * sort_books(): receives an array of struct book's, of length
 * numBooks.  Sorts the array in-place (i.e., actually modifies
 * the elements of the array).
 *
 * This is almost exactly what was given in the pseudocode in
 * the project spec, STUBS replaced with real code
 */
void sort_books(struct book books[], int numBooks) {
    int i, j, min, cmpResult;

    /* use selection sort to sort books in array */
    for (i = 0; i < numBooks - 1; i++) {
        min = i;
        for (j = i + 1; j < numBooks; j++) {

            /* Copy pointers to the two books to be compared into the
             * global variables book1 and book2 for bookcmp() to see
             */
            book1 = &books[min];
            book2 = &books[j];
            
            cmpResult = bookcmp();
            
            /* bookcmp returns result in register EAX--above saves
             * it into cmpResult */
            
            /* if book2 is less than book1 set min */
            if (cmpResult == 1) {
                min = j;
            }
        }
        /* if min was found at other index, swap */
        if (min != i) {
            struct book temp = books[i];
            books[i] =  books[min];
            books[min] = temp;
        }
    }
}


/* Function print_books takes in array of book structs and length of array to print
 * out all book contents of array */
void print_books(struct book books[], int numBooks) {

    /* print out fields of book structures in array of structs */
    int i;
    for(i = 0; i < numBooks; ++i) {
        printf("%s, %s, %s, %u\n",
               books[i].title, books[i].author, books[i].subject, books[i].year);
    }
}
