<?php

namespace App\Services;

use App\Models\Category;
use App\Models\Product;
use App\Models\Tax;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Str;

class ProductImportService
{
    public function import(UploadedFile $file, int $tenantId): array
    {
        $handle = fopen($file->getRealPath(), 'r');
        if (!$handle) {
            return $this->result(0, 0, 1, [['row' => 0, 'message' => 'Unable to read file.']]);
        }

        $headerInfo = $this->readHeader($handle);
        if ($headerInfo === null) {
            fclose($handle);
            return $this->result(0, 0, 1, [['row' => 0, 'message' => 'CSV header not found.']]);
        }
        $header = $headerInfo['header'];
        $delimiter = $headerInfo['delimiter'];

        $rowNumber = 1;
        $headerSet = array_flip($header);
        $created = 0;
        $updated = 0;
        $skipped = 0;
        $errors = [];

        while (($row = fgetcsv($handle, 0, $delimiter)) !== false) {
            $rowNumber++;
            if ($this->isRowEmpty($row)) {
                continue;
            }

            $values = array_pad($row, count($header), null);
            $data = array_combine($header, $values);
            if ($data === false) {
                $skipped++;
                $errors[] = ['row' => $rowNumber, 'message' => 'Invalid row format.'];
                continue;
            }

            $name = trim((string) ($data['name'] ?? ''));
            $price = $this->toFloat($data['price'] ?? null);
            if ($name === '' || $price === null) {
                $skipped++;
                $errors[] = ['row' => $rowNumber, 'message' => 'Missing required name/price.'];
                continue;
            }

            $sku = $this->cleanString($data['sku'] ?? null);
            $barcode = $this->cleanString($data['barcode'] ?? null);
            $cost = $this->toFloat($data['cost'] ?? null);
            $description = $this->cleanString($data['description'] ?? null);
            $trackStock = $this->toBool($data['track_stock'] ?? null, true);
            $isActive = $this->toBool($data['is_active'] ?? null, true);
            $imageUrl = $this->cleanString($data['image_url'] ?? null);

            $payload = [
                'tenant_id' => $tenantId,
                'name' => $name,
                'price' => $price,
            ];
            if (isset($headerSet['sku'])) {
                $payload['sku'] = $sku;
            }
            if (isset($headerSet['barcode'])) {
                $payload['barcode'] = $barcode;
            }
            if (isset($headerSet['cost'])) {
                $payload['cost'] = $cost ?? 0;
            }
            if (isset($headerSet['description'])) {
                $payload['description'] = $description;
            }
            if (isset($headerSet['track_stock'])) {
                $payload['track_stock'] = $trackStock;
            }
            if (isset($headerSet['is_active'])) {
                $payload['is_active'] = $isActive;
            }
            if (isset($headerSet['image_url'])) {
                $payload['image_url'] = $imageUrl;
            }

            if (isset($headerSet['category'])) {
                $categoryId = null;
                $categoryName = $this->cleanString($data['category'] ?? null);
                if ($categoryName) {
                    $category = Category::firstOrCreate(
                        ['tenant_id' => $tenantId, 'name' => $categoryName],
                        ['is_active' => true]
                    );
                    $categoryId = $category->id;
                }
                $payload['category_id'] = $categoryId;
            }

            if (isset($headerSet['tax'])) {
                $taxId = null;
                $taxName = $this->cleanString($data['tax'] ?? null);
                if ($taxName) {
                    $tax = Tax::where('tenant_id', $tenantId)->where('name', $taxName)->first();
                    $taxId = $tax?->id;
                }
                $payload['tax_id'] = $taxId;
            }

            if ($sku) {
                $product = Product::where('tenant_id', $tenantId)->where('sku', $sku)->first();
                if ($product) {
                    $product->update($payload);
                    $updated++;
                    continue;
                }
            }

            $payload['uuid'] = (string) Str::uuid();
            if (!isset($payload['cost'])) {
                $payload['cost'] = $cost ?? 0;
            }
            if (!isset($payload['track_stock'])) {
                $payload['track_stock'] = true;
            }
            if (!isset($payload['is_active'])) {
                $payload['is_active'] = true;
            }
            Product::create($payload);
            $created++;
        }

        fclose($handle);

        return $this->result($created, $updated, $skipped, $errors);
    }

    private function readHeader($handle): ?array
    {
        $firstLine = null;
        while (($line = fgets($handle)) !== false) {
            if (trim($line) !== '') {
                $firstLine = $line;
                break;
            }
        }
        if ($firstLine === null) {
            return null;
        }

        $delimiter = $this->detectDelimiter($firstLine);
        $header = str_getcsv($firstLine, $delimiter);
        $header = array_map(function ($value) {
            $value = preg_replace('/^\xEF\xBB\xBF/', '', (string) $value);
            $value = strtolower(trim($value));
            $value = str_replace([' ', '-'], '_', $value);
            return $value;
        }, $header);

        $header = $this->normalizeHeader($header);

        if (!in_array('name', $header, true) || !in_array('price', $header, true)) {
            return null;
        }

        return [
            'header' => $header,
            'delimiter' => $delimiter,
        ];
    }

    private function normalizeHeader(array $header): array
    {
        $map = [
            'product_name' => 'name',
            'product' => 'name',
            'category_name' => 'category',
            'tax_name' => 'tax',
            'image' => 'image_url',
            'imageurl' => 'image_url',
        ];

        return array_map(function ($value) use ($map) {
            return $map[$value] ?? $value;
        }, $header);
    }

    private function detectDelimiter(string $line): string
    {
        $delimiters = [',', ';', "\t"];
        $best = ',';
        $maxCount = -1;
        foreach ($delimiters as $delimiter) {
            $count = substr_count($line, $delimiter);
            if ($count > $maxCount) {
                $maxCount = $count;
                $best = $delimiter;
            }
        }
        return $best;
    }

    private function isRowEmpty(array $row): bool
    {
        foreach ($row as $value) {
            if (trim((string) $value) !== '') {
                return false;
            }
        }
        return true;
    }

    private function cleanString($value): ?string
    {
        if ($value === null) {
            return null;
        }
        $value = trim((string) $value);
        return $value === '' ? null : $value;
    }

    private function toFloat($value): ?float
    {
        if ($value === null || $value === '') {
            return null;
        }
        if (is_numeric($value)) {
            return (float) $value;
        }
        $value = str_replace(',', '.', (string) $value);
        return is_numeric($value) ? (float) $value : null;
    }

    private function toBool($value, bool $default): bool
    {
        if ($value === null || $value === '') {
            return $default;
        }
        if (is_bool($value)) {
            return $value;
        }
        if (is_numeric($value)) {
            return (int) $value !== 0;
        }
        $normalized = strtolower(trim((string) $value));
        if (in_array($normalized, ['true', 'yes', 'y', '1'], true)) {
            return true;
        }
        if (in_array($normalized, ['false', 'no', 'n', '0'], true)) {
            return false;
        }
        return $default;
    }

    private function result(int $created, int $updated, int $skipped, array $errors): array
    {
        return [
            'created' => $created,
            'updated' => $updated,
            'skipped' => $skipped,
            'errors' => $errors,
        ];
    }
}
