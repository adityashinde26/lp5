#include <iostream>
#include <chrono>
#include <cstdlib>
#include <omp.h>
#include <iomanip>
#include <algorithm>

using namespace std;
using namespace chrono;

void print_array(int arr[], int size)
{
    cout << "Array: [ ";
    for (int i = 0; i < size; i++)
    {
        cout << arr[i] << " ";
    }
    cout << "]\n";
}

void merge(int arr[], int left, int mid, int right)
{
    int temp[right - left + 1];
    int i = left;
    int j = mid + 1;
    int k = 0;

    while (i <= mid && j <= right)
    {
        temp[k++] = (arr[i] < arr[j]) ? arr[i++] : arr[j++];
    }

    while (i <= mid)
    {
        temp[k++] = arr[i++];
    }

    while (j <= right)
    {
        temp[k++] = arr[j++];
    }

    copy(temp, temp + k, arr + left);
}

void sequential_merge_sort(int arr[], int left, int right)
{
    if (left < right)
    {
        int mid = (left + right) / 2;

        sequential_merge_sort(arr, left, mid);
        sequential_merge_sort(arr, mid + 1, right);

        merge(arr, left, mid, right);
    }
}

void parallel_merge_sort(int arr[], int left, int right)
{
    if (left < right)
    {
        int mid = (left + right) / 2;

        #pragma omp parallel sections
        {
            #pragma omp section
            parallel_merge_sort(arr, left, mid);

            #pragma omp section
            parallel_merge_sort(arr, mid + 1, right);
        }

        merge(arr, left, mid, right);
    }
}

int main()
{
    int size;

    cout << "Enter size of array: ";
    cin >> size;

    int arr[size];

    for (int i = 0; i < size; i++)
    {
        arr[i] = rand() % size;
    }

    cout << "\nInput Array: ";
    print_array(arr, size);

    int seq_arr[size];
    copy(arr, arr + size, seq_arr);

    auto start = high_resolution_clock::now();
    sequential_merge_sort(seq_arr, 0, size - 1);
    auto end = high_resolution_clock::now();

    double seq_time = duration<double>(end - start).count();

    cout << "\nSequential Merge Sort Time: "
         << fixed << setprecision(10) << seq_time << " s\n";

    print_array(seq_arr, size);

    int par_arr[size];
    copy(arr, arr + size, par_arr);

    start = high_resolution_clock::now();
    parallel_merge_sort(par_arr, 0, size - 1);
    end = high_resolution_clock::now();

    double par_time = duration<double>(end - start).count();

    cout << "\nParallel Merge Sort Time: "
         << fixed << setprecision(10) << par_time << " s\n";

    print_array(par_arr, size);

    cout << "\nSpeedup: "
         << fixed << setprecision(10) << seq_time / par_time << "\n";

    return 0;
}
//g++ filename.cpp -fopenmp -o filename
// ./filename