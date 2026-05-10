#include <iostream>
#include <vector>
#include <omp.h>

using namespace std;

// Serial Minimum
int serialMin(vector<int>& arr)
{
    int minVal = arr[0];

    for (int i = 0; i < arr.size(); i++)
    {
        if (arr[i] < minVal)
        {
            minVal = arr[i];
        }
    }

    return minVal;
}

// Parallel Minimum
int parallelMin(vector<int>& arr)
{
    int minVal = arr[0];

    #pragma omp parallel for reduction(min:minVal)
    for (int i = 0; i < arr.size(); i++)
    {
        if (arr[i] < minVal)
        {
            minVal = arr[i];
        }
    }

    return minVal;
}

// Serial Maximum
int serialMax(vector<int>& arr)
{
    int maxVal = arr[0];

    for (int i = 0; i < arr.size(); i++)
    {
        if (arr[i] > maxVal)
        {
            maxVal = arr[i];
        }
    }

    return maxVal;
}

// Parallel Maximum
int parallelMax(vector<int>& arr)
{
    int maxVal = arr[0];

    #pragma omp parallel for reduction(max:maxVal)
    for (int i = 0; i < arr.size(); i++)
    {
        if (arr[i] > maxVal)
        {
            maxVal = arr[i];
        }
    }

    return maxVal;
}

// Serial Sum
int serialSum(vector<int>& arr)
{
    int sum = 0;

    for (int i = 0; i < arr.size(); i++)
    {
        sum += arr[i];
    }

    return sum;
}

// Parallel Sum
int parallelSum(vector<int>& arr)
{
    int sum = 0;

    #pragma omp parallel for reduction(+:sum)
    for (int i = 0; i < arr.size(); i++)
    {
        sum += arr[i];
    }

    return sum;
}

// Serial Average
double serialAverage(vector<int>& arr)
{
    int sum = serialSum(arr);

    return (double)sum / arr.size();
}

// Parallel Average
double parallelAverage(vector<int>& arr)
{
    int sum = parallelSum(arr);

    return (double)sum / arr.size();
}

int main()
{
    vector<int> arr = {10, 20, 5, 40, 15, 35, 50, 25};

    // Serial Performance
    double start1 = omp_get_wtime();

    int sMin = serialMin(arr);
    int sMax = serialMax(arr);
    int sSum = serialSum(arr);
    double sAvg = serialAverage(arr);

    double end1 = omp_get_wtime();

    double sequentialTime = end1 - start1;

    // Parallel Performance
    double start2 = omp_get_wtime();

    int pMin = parallelMin(arr);
    int pMax = parallelMax(arr);
    int pSum = parallelSum(arr);
    double pAvg = parallelAverage(arr);

    double end2 = omp_get_wtime();

    double parallelTime = end2 - start2;

    // Output
    cout << "Array Elements: ";

    for (int x : arr)
    {
        cout << x << " ";
    }

    // Serial Results
    cout << "\n\n----- Serial Results -----";

    cout << "\nMinimum = " << sMin;
    cout << "\nMaximum = " << sMax;
    cout << "\nSum = " << sSum;
    cout << "\nAverage = " << sAvg;

    // Parallel Results
    cout << "\n\n----- Parallel Results -----";

    cout << "\nMinimum = " << pMin;
    cout << "\nMaximum = " << pMax;
    cout << "\nSum = " << pSum;
    cout << "\nAverage = " << pAvg;

    // Performance
    cout << "\n\nSequential Time = "
         << sequentialTime << " seconds";

    cout << "\nParallel Time = "
         << parallelTime << " seconds";

    // Speedup
    cout << "\nSpeedup = "
         << sequentialTime / parallelTime;

    return 0;
}
//g++ filename.cpp -fopenmp -o filename
// ./filename
