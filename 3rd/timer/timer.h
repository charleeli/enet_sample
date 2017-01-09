#ifndef TIMER_H
#define TIMER_H

typedef struct timer timer_s;

timer_s * timer_create2();
void timer_destroy(timer_s *timer);

void timer_add(timer_s *timer, unsigned long id, unsigned long elapse);
void timer_delete2(timer_s *timer, unsigned long id);
void timer_delete_all(timer_s *timer);

typedef void (* timer_execute_ptr)(unsigned long id, void *userp);

void timer_expire(timer_s *timer, timer_execute_ptr execute, void *userp);

#endif /* TIMER_H */
